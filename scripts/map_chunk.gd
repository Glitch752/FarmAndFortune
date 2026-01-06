
class_name MapChunk

var async_debounce = preload("res://scripts/utils.gd").async_debounce

var chunk_position: Vector2i = Vector2i.ZERO

var terrain_types: PackedByteArray
var crops: Dictionary[Vector2i, WorldCrop] = {}

var _cell_geometry_cache: Dictionary[Vector2i, Array] = {}
# Thread safety: We only sequentially access this after generating it in a thread.
var grass_transforms: Array[Transform2D] = []
var transforms_mutex: Mutex = Mutex.new()

signal regenerate_terrain()
signal terrain_regenerated()

signal regenerate_grass()

var _half_tile_changed_debounce = async_debounce.call(_half_tile_changed)
func half_tile_changed():
    _half_tile_changed_debounce.call([])

# Called when the half-tile offset chunk around this one is changed
# (meaning either this chunk or an up/left neighbor).
# Used to regenerate chunks
func _half_tile_changed():
    print("half-tile changed for chunk %s, regenerating terrain and grass" % chunk_position)

    regenerate_terrain.emit.call_deferred()
    await terrain_regenerated

    await ThreadPool.get_instance().submit(self.generate_grass_transforms)
    
    regenerate_grass.emit()

signal unlocked_changed(new_unlocked: bool)
var unlocked: bool = false:
    set(val):
        if unlocked != val:
            unlocked = val
            unlocked_changed.emit(val)

static var grass_position_candidates: PackedFloat32Array = []
static var grass_scale_cache: PackedFloat32Array = []
static var scatter_count = 250 * MapSingleton.CHUNK_SIZE * MapSingleton.CHUNK_SIZE
static var scatter_extent = MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE / float(2)
static func generate_grass_position_candidates():
    var base_scale = 0.6

    for i in scatter_count:
        var x = randf() * scatter_extent * 2
        grass_position_candidates.append(x)
        grass_scale_cache.append(randf() * base_scale + base_scale)


func generate_grass_transforms():
    if grass_position_candidates.size() == 0:
        generate_grass_position_candidates()

    var start_time = Time.get_ticks_msec()

    transforms_mutex.lock()

    grass_transforms.clear()
    grass_transforms.resize(scatter_count)
    var idx = 0
    for i in scatter_count:
        var x = grass_position_candidates[i]
        var y = float(i) / scatter_count * scatter_extent * 2

        if not check_grass_at_position(Vector2(x, y)):
            continue
        
        var instance_transform = Transform2D()\
            .scaled(Vector2.ONE * grass_scale_cache[i])\
            .translated(Vector2(x, y))

        grass_transforms[idx] = instance_transform
        idx += 1
    grass_transforms.resize(idx)

    transforms_mutex.unlock()

    print_rich("[color=green]Generated grass positions for chunk %s in %d ms, %d instances[/color]" %
        [chunk_position, Time.get_ticks_msec() - start_time, grass_transforms.size()])

func check_grass_at_position(local_pos: Vector2) -> bool:
    var grid_x = floori(local_pos.x / MapSingleton.TILE_SIZE)
    var grid_y = floori(local_pos.y / MapSingleton.TILE_SIZE)
    var tile = Vector2i(grid_x, grid_y)
    
    # if outside our grid, we return true since it's grass in the neighboring chunk
    if not is_tile_in_chunk(tile):
        return true

    # check if this cell has any terrain geometry
    if not _cell_geometry_cache.has(tile):
        return false
    
    var polys = _cell_geometry_cache[tile]
    for poly in polys:
        if Geometry2D.is_point_in_polygon(local_pos, poly):
            return true
            
    return false

func is_tile_in_chunk(tile: Vector2i) -> bool:
    return tile.x >= 0 and tile.x < MapSingleton.CHUNK_SIZE and tile.y >= 0 and tile.y < MapSingleton.CHUNK_SIZE

func get_terrain_at(local_pos: Vector2i) -> MapSingleton.TerrainType:
    var index = local_pos.y * MapSingleton.CHUNK_SIZE + local_pos.x
    if index < 0 or index >= terrain_types.size():
        return MapSingleton.TerrainType.NONE
    return terrain_types[index] as MapSingleton.TerrainType

## Sets the terrain at the given local position and returns if it changed.
## Doesn't emit signals.
func set_terrain_at(local_pos: Vector2i, terrain: MapSingleton.TerrainType) -> bool:
    var index = local_pos.y * MapSingleton.CHUNK_SIZE + local_pos.x
    if index < 0 or index >= terrain_types.size():
        return false
    if terrain_types[index] == terrain:
        return false
    terrain_types[index] = terrain
    return true

signal crop_node_added(local_pos: Vector2i, crop: WorldCrop)
signal crop_node_removed(local_pos: Vector2i)

## Get the crop at the given local position
func get_crop_at(local_pos: Vector2i) -> WorldCrop:
    if not is_tile_in_chunk(local_pos):
        return null
    if crops.has(local_pos):
        return crops[local_pos]
    return null

## Set the crop at the given local position
func set_crop_at(local_pos: Vector2i, crop: WorldCrop) -> void:
    if not is_tile_in_chunk(local_pos):
        return
    
    if crop == null:
        crops.erase(local_pos)
        crop_node_removed.emit(local_pos)
    else:
        crops[local_pos] = crop
        crop_node_added.emit(local_pos, crop)
    should_process = crops.size() > 0


signal should_process_changed(should_process: bool)
var should_process: bool = false:
    set(value):
        if should_process != value:
            should_process = value
            should_process_changed.emit(value)

## A timer from 0-1 to track the crop we're currently processing
var crop_process_timer: float = 0.0
const CROP_PROCESS_INTERVAL = preload("res://scripts/map/world_crop.gd").CROP_PROCESS_INTERVAL

func get_pos_at_index(index: int) -> Vector2i:
    var x = index % MapSingleton.CHUNK_SIZE
    @warning_ignore("integer_division")
    var y = index / MapSingleton.CHUNK_SIZE
    return Vector2i(x, y)

const TOTAL_CROPS = MapSingleton.CHUNK_SIZE * MapSingleton.CHUNK_SIZE

func _process_range(start_index: int, end_index: int) -> void:
    for i in range(start_index, end_index):
        var tile_pos = get_pos_at_index(i)
        if crops.has(tile_pos):
            var crop = crops[tile_pos]
            crop.process()

func _process(delta: float) -> void:
    var previous_process_timer = crop_process_timer

    crop_process_timer += delta / CROP_PROCESS_INTERVAL

    var start_index = int(floor(previous_process_timer * TOTAL_CROPS))

    if crop_process_timer >= 1.0:
        crop_process_timer -= 1.0

    var end_index = int(floor(crop_process_timer * TOTAL_CROPS))

    if end_index > start_index:
        _process_range(start_index, end_index)
    elif end_index < start_index:
        _process_range(start_index, TOTAL_CROPS)
        _process_range(0, end_index)

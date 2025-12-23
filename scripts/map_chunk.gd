
class_name MapChunk

var chunk_position: Vector2i = Vector2i.ZERO

var terrain_types: PackedByteArray

var _cell_geometry_cache: Dictionary[Vector2i, Array] = {}
var grass_transforms: Array[Transform2D] = []

signal regenerate_terrain()
signal regenerate_grass()

# Called when the half-tile offset chunk around this one is changed
# (meaning either this chunk or an up/left neighbor).
# Used to regenerate chunks
func half_tile_changed():
    regenerate_terrain.emit()

    generate_grass_transforms()
    
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
    
    grass_transforms = []

    var start_time = Time.get_ticks_msec()

    for i in scatter_count:
        var x = grass_position_candidates[i]
        var y = float(i) / scatter_count * scatter_extent * 2

        if not check_grass_at_position(Vector2(x, y)):
            continue
        
        var instance_transform = Transform2D()\
            .scaled(Vector2.ONE * grass_scale_cache[i])\
            .translated(Vector2(x, y))

        grass_transforms.append(instance_transform)

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


class_name MapChunk

var chunk_position: Vector2i = Vector2i.ZERO

var terrain_types: PackedByteArray

var _cell_geometry_cache: Dictionary[Vector2i, Array] = {}
var grass_transforms: Array[Transform2D] = []

signal unlocked_changed(new_unlocked: bool)
var unlocked: bool = false:
    set(val):
        if unlocked != val:
            unlocked = val
            unlocked_changed.emit(val)

func generate_grass_position_cache():
    var extent = MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE / float(2)

    var scatter_count = 250 * MapSingleton.CHUNK_SIZE * MapSingleton.CHUNK_SIZE
    var base_scale = 0.6
    var side_margin = base_scale * 1.5

    for i in scatter_count:
        var x = randf() * extent * 2 - extent
        var y = float(i) / scatter_count * extent * 2 - extent

        if not check_grass_at_position(Vector2(
            x + extent,
            y + extent
        )):
            continue
        
        var instance_scale = randf() * base_scale + base_scale
        var instance_transform = Transform2D()\
            .scaled(Vector2.ONE * instance_scale)\
            .translated(Vector2(x, y))

        grass_transforms.append(instance_transform)

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

func _get_terrain_at(local_pos: Vector2i) -> int:
    var index = local_pos.y * MapSingleton.CHUNK_SIZE + local_pos.x
    if index < 0 or index >= terrain_types.size():
        return -1
    return terrain_types[index]

func is_tile_in_chunk(tile: Vector2i) -> bool:
    return tile.x >= 0 and tile.x < MapSingleton.CHUNK_SIZE and tile.y >= 0 and tile.y < MapSingleton.CHUNK_SIZE
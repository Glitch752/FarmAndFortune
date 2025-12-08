
class_name MapChunk

var terrain_types: PackedByteArray

func _get_terrain_at(local_pos: Vector2i) -> int:
    var index = local_pos.y * MapSingleton.CHUNK_SIZE + local_pos.x
    if index < 0 or index >= terrain_types.size():
        return -1
    return terrain_types[index]

func is_tile_in_chunk(tile: Vector2i) -> bool:
    return tile.x >= 0 and tile.x < MapSingleton.CHUNK_SIZE and tile.y >= 0 and tile.y < MapSingleton.CHUNK_SIZE
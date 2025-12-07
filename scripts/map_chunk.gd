
class_name MapChunk

var terrain_types: PackedByteArray

func _get_terrain_at(local_pos: Vector2i) -> int:
    var index = local_pos.y * MapSingleton.CHUNK_SIZE + local_pos.x
    if index < 0 or index >= terrain_types.size():
        return -1
    return terrain_types[index]
extends Node

const TILE_SIZE = 16
const CHUNK_SIZE = 10
# In chunks
const MAP_SIZE = 16

enum TerrainType {
    GRASS,
    WATER
}

var chunks: Dictionary[Vector2i, MapChunk] = {}

func get_chunk_at(chunk_pos: Vector2i) -> MapChunk:
    return chunks.get(chunk_pos, null)
func get_terrain_at(tile_pos: Vector2i) -> int:
    var chunk_pos = Vector2i(
        floor(tile_pos.x / float(CHUNK_SIZE)),
        floor(tile_pos.y / float(CHUNK_SIZE))
    )
    var local_pos = Vector2i(
        tile_pos.x % CHUNK_SIZE,
        tile_pos.y % CHUNK_SIZE
    )
    var chunk = get_chunk_at(chunk_pos)
    if chunk == null:
        return -1
    return chunk._get_terrain_at(local_pos)
func get_terrain_at_world(world_pos: Vector2) -> int:
    var tile_pos = Vector2i(
        floor(world_pos.x / float(TILE_SIZE)),
        floor(world_pos.y / float(TILE_SIZE))
    )
    return get_terrain_at(tile_pos)

func _init():
    _generate_map()

func _generate_map():
    chunks = {}

    for x in MAP_SIZE:
        for y in MAP_SIZE:
            var chunk_pos = Vector2i(x, y)
            var chunk = MapChunk.new()
            chunk.terrain_types = PackedByteArray()
            for i in CHUNK_SIZE * CHUNK_SIZE:
                chunk.terrain_types.append(
                    TerrainType.GRASS if randf() < 0.8 else TerrainType.WATER
                )
            chunks[chunk_pos] = chunk

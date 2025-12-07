extends Node

const CHUNK_SIZE = 10
# In chunks
const MAP_SIZE = 16

enum TerrainType {
    GRASS,
    WATER
}

class MapChunk:
    var terrain_types: PackedByteArray

var chunks: Dictionary[Vector2i, MapChunk] = {}

func _ready():
    _generate_map()

func _generate_map():
    chunks = {}

    for x in MAP_SIZE:
        for y in MAP_SIZE:
            var chunk_pos = Vector2i(x, y)
            var chunk = MapChunk.new()
            chunk.terrain_types = PackedByteArray()
            for i in CHUNK_SIZE * CHUNK_SIZE:
                chunk.terrain_types.append(TerrainType.GRASS)
            chunks[chunk_pos] = chunk

extends Node

const TILE_SIZE = 16
const CHUNK_SIZE = 10
# In chunks
const MAP_SIZE = 8

enum TerrainType {
    GRASS,
    WATER
}

var chunks: Dictionary[Vector2i, MapChunk] = {}

func get_chunk_at(chunk_pos: Vector2i) -> MapChunk:
    return chunks.get(chunk_pos, null)
func get_chunk_at_world(world_pos: Vector2) -> MapChunk:
    var chunk_pos = Vector2i(
        floor(world_pos.x / float(CHUNK_SIZE * TILE_SIZE)),
        floor(world_pos.y / float(CHUNK_SIZE * TILE_SIZE))
    )
    return get_chunk_at(chunk_pos)
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

func check_grass_at_position(pos: Vector2):
    var chunk = get_chunk_at_world(pos)
    if chunk == null:
        return false
    var local_pos = pos - Vector2(
        chunk.chunk_position.x * CHUNK_SIZE * TILE_SIZE,
        chunk.chunk_position.y * CHUNK_SIZE * TILE_SIZE
    )
    return chunk.check_grass_at_position(local_pos)

func _init():
    _generate_map()

func _generate_map():
    chunks = {}

    var noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.05
    noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
    noise.fractal_type = FastNoiseLite.FractalType.FRACTAL_FBM
    noise.fractal_octaves = 2
    noise.fractal_gain = 0.4

    var center = Vector2(MAP_SIZE / 2.0, MAP_SIZE / 2.0)
    
    # We need to generate 1 more chunk than the map size to cover all tiles
    for x in MAP_SIZE + 1:
        for y in MAP_SIZE + 1:
            var chunk_pos = Vector2i(x, y)
            var chunk = MapChunk.new()
            chunk.chunk_position = chunk_pos
            chunk.terrain_types = PackedByteArray()

            # If this chunk is within a radius of the center of the map, unlock it
            if chunk_pos.distance_to(center) < MAP_SIZE / 2.0:
                chunk.unlocked = true
            
            for i in CHUNK_SIZE * CHUNK_SIZE:
                var noise_val = noise.get_noise_2d(
                    chunk_pos.x * CHUNK_SIZE + (i % CHUNK_SIZE),
                    chunk_pos.y * CHUNK_SIZE + (i / CHUNK_SIZE)
                )
                chunk.terrain_types.append(
                    TerrainType.GRASS if noise_val > 0.0 else TerrainType.WATER
                )
            chunks[chunk_pos] = chunk

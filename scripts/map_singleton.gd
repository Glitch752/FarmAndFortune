extends Node

const TILE_SIZE = 16
const CHUNK_SIZE = 10
# In chunks
const MAP_SIZE = 9

enum TerrainType {
    NONE,
    GRASS,
    SOIL,
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

func get_terrain_at(tile_pos: Vector2i) -> TerrainType:
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
        return TerrainType.NONE
    return chunk.get_terrain_at(local_pos)
func get_terrain_at_world(world_pos: Vector2) -> TerrainType:
    var tile_pos = Vector2i(
        floor(world_pos.x / float(TILE_SIZE)),
        floor(world_pos.y / float(TILE_SIZE))
    )
    return get_terrain_at(tile_pos)

func set_terrain_at(tile_pos: Vector2i, terrain: TerrainType) -> void:
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
        return
    if chunk.set_terrain_at(local_pos, terrain):
        # The tile changed; update all required chunks
        chunk.half_tile_changed()
        if local_pos.x == 0:
            var left_chunk = get_chunk_at(chunk_pos + Vector2i(-1, 0))
            if left_chunk != null:
                left_chunk.half_tile_changed()
        if local_pos.y == 0:
            var up_chunk = get_chunk_at(chunk_pos + Vector2i(0, -1))
            if up_chunk != null:
                up_chunk.half_tile_changed()
        if local_pos.x == 0 and local_pos.y == 0:
            var up_left_chunk = get_chunk_at(chunk_pos + Vector2i(-1, -1))
            if up_left_chunk != null:
                up_left_chunk.half_tile_changed()

func tile_to_world_position(tile_pos: Vector2i) -> Vector2:
    return Vector2(
        tile_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
        tile_pos.y * TILE_SIZE + TILE_SIZE / 2.0
    )
func world_to_tile_position(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        floor(world_pos.x / float(TILE_SIZE)),
        floor(world_pos.y / float(TILE_SIZE))
    )

func check_grass_at_position(pos: Vector2):
    pos = pos - Vector2.ONE * TILE_SIZE / 2.
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
    var tile_center = center * CHUNK_SIZE
    
    # We need to generate 1 more chunk than the map size to cover all tiles
    for x in MAP_SIZE:
        for y in MAP_SIZE:
            var chunk_pos = Vector2i(x, y)

            var chunk = MapChunk.new()
            chunk.chunk_position = chunk_pos
            chunk.terrain_types = PackedByteArray()

            # If this chunk is within a radius of the center of the map, unlock it
            if chunk_pos.distance_to(center) < 0.8:
                chunk.unlocked = true
            
            # TODO: make the map more... river-y? and not island-y
            # this should feel like a forest, not a lake with land in it...

            for i in CHUNK_SIZE * CHUNK_SIZE:
                @warning_ignore("integer_division")
                var tile_pos = Vector2i(
                    chunk_pos.x * CHUNK_SIZE + (i % CHUNK_SIZE),
                    chunk_pos.y * CHUNK_SIZE + (i / CHUNK_SIZE)
                )

                var noise_val = noise.get_noise_2d(tile_pos.x, tile_pos.y)

                # Add a small radius of guarenteed land at the center of the map
                # to make sure the player always has a starting area
                var center_radius = CHUNK_SIZE * 0.9
                noise_val += clamp(
                    (center_radius - tile_pos.distance_to(tile_center)) / center_radius,
                    0.0,
                    1.5
                )

                chunk.terrain_types.append(
                    TerrainType.GRASS if noise_val > 0.0 else TerrainType.WATER
                )
            chunks[chunk_pos] = chunk

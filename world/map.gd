extends Node2D

const ChunkScene = preload("res://scenes/Chunk.tscn")

func _ready():
    for x in MapSingleton.MAP_SIZE:
        for y in MapSingleton.MAP_SIZE:
            var chunk: Node2D = ChunkScene.instantiate()

            chunk.chunk_position = Vector2i(x, y)
            chunk.position = Vector2(
                x * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE,
                y * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
            )
            chunk.generate()
            
            add_child(chunk)

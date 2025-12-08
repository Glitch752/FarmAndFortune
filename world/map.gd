extends Node2D

const ChunkScene = preload("res://scenes/Chunk.tscn")

@onready var camera = $"Camera2D"
@onready var chunks_node = $"Chunks"

func _ready():
    var chunks = []
    for x in MapSingleton.MAP_SIZE:
        for y in MapSingleton.MAP_SIZE:
            var chunk: Node2D = ChunkScene.instantiate()

            chunk.chunk_position = Vector2i(x, y)
            chunk.position = Vector2(
                x * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE,
                y * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
            )
            chunk.generate()

            chunks.append(chunk)
    
    for chunk in chunks:
        chunks_node.add_child(chunk)

    # Place the camera in the center of the world and set its
    # limits to the world size
    var world_size = MapSingleton.MAP_SIZE * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
    camera.position = Vector2(world_size, world_size) / 2.0
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = world_size
    camera.limit_bottom = world_size

# Find what chunks are visible and update them if they are
func _process(_delta):
    var viewport_rect = Rect2(
        camera.position - (get_viewport_rect().size / 2.0) / camera.zoom,
        get_viewport_rect().size / camera.zoom
    )

    # TODO: This could be optimized, but like... whatever
    for chunk in chunks_node.get_children():
        var chunk_rect = Rect2(
            chunk.position,
            chunk.size
        )

        var chunk_visible = viewport_rect.intersects(chunk_rect)
        if chunk_visible != chunk.visible_to_camera:
            chunk.camera_visibility_changed.emit(chunk_visible)

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

            if x == floor(MapSingleton.MAP_SIZE / 2.) and y == floor(MapSingleton.MAP_SIZE / 2.):
                chunk.name = "Origin"

            chunks.append(chunk)
    
    for chunk in chunks:
        chunks_node.add_child(chunk)

    # Place the camera in the center of the world and set its
    # limits to the world size
    var world_size = MapSingleton.MAP_SIZE * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
    camera.position = Vector2(world_size, world_size) / 2.0
    camera.limit_left = MapSingleton.TILE_SIZE / 2.0
    camera.limit_top = MapSingleton.TILE_SIZE / 2.0
    camera.limit_right = world_size - MapSingleton.TILE_SIZE / 2.0
    camera.limit_bottom = world_size - MapSingleton.TILE_SIZE / 2.0

# Find what chunks are visible and update them if they are
func _process(_delta: float) -> void:
    var viewport_rect = Rect2(
        camera.position - (get_viewport_rect().size / 2.0) / camera.zoom,
        get_viewport_rect().size / camera.zoom
    )
    var rect_margin = 10.0
    viewport_rect.position -= Vector2.ONE * rect_margin
    viewport_rect.size += Vector2.ONE * rect_margin * 2.0

    # TODO: This could be optimized, but like... whatever
    for chunk in chunks_node.get_children():
        var chunk_rect = Rect2(
            chunk.position,
            chunk.size
        )

        var chunk_visible = viewport_rect.intersects(chunk_rect)
        if chunk_visible != chunk.visible_to_camera:
            chunk.camera_visibility_changed.emit(chunk_visible)

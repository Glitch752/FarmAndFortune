extends Node2D

var chunk_position: Vector2i = Vector2i.ZERO
var chunk_data: MapChunk

var visible_to_camera: bool = false
signal camera_visibility_changed(new_visibility: bool)

var size: Vector2:
    get:
        return Vector2(
            MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE,
            MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
        )

func generate() -> void:
    chunk_data = MapSingleton.get_chunk_at(chunk_position)

    $%Ground/UnderMesh.init(chunk_data, chunk_position)

    chunk_data.generate_grass_position_cache()

func _ready():
    camera_visibility_changed.connect(_on_camera_visibility_changed)

    queue_redraw()

    $%Ground.position = Vector2.ONE * MapSingleton.TILE_SIZE / 2.

func _on_camera_visibility_changed(new_visibility: bool) -> void:
    visible_to_camera = new_visibility

    #if new_visibility:
        #var grass = preload("./grass/grass.tscn").instantiate()
        #grass.position = Vector2.ONE * (MapSingleton.TILE_SIZE * MapSingleton.CHUNK_SIZE / 2.)
        #grass.name = "Grass"
        #$%Ground.add_child(grass)
    #else:
        #var grass = $%Ground.get_node_or_null("Grass")
        #if grass:
            #grass.queue_free()

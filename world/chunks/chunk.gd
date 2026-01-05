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

    for ground_mesh in $%Ground.get_children():
        ground_mesh.init(chunk_data, chunk_position)

    chunk_data.generate_grass_transforms()

func _ready():
    camera_visibility_changed.connect(_on_camera_visibility_changed)

    queue_redraw()

    $%Ground.position = Vector2.ONE * MapSingleton.TILE_SIZE / 2.

    chunk_data.crop_node_added.connect(_on_crop_node_added)
    chunk_data.crop_node_removed.connect(_on_crop_node_removed)

func _on_crop_node_added(local_pos: Vector2i, crop: WorldCrop) -> void:
    var crop_node = crop.node
    crop_node.position = Vector2(
        local_pos.x * MapSingleton.TILE_SIZE,
        local_pos.y * MapSingleton.TILE_SIZE
    )
    crop_node.name = "Crop_%d_%d" % [local_pos.x, local_pos.y]
    $%Crops.add_child(crop_node)

func _on_crop_node_removed(local_pos: Vector2i) -> void:
    var crop_node = $%Crops.get_node_or_null("Crop_%d_%d" % [local_pos.x, local_pos.y])
    if crop_node:
        crop_node.queue_free()

func _on_camera_visibility_changed(new_visibility: bool) -> void:
    visible_to_camera = new_visibility

    if new_visibility:
        var grass = preload("./grass/grass.tscn").instantiate()
        grass.name = "Grass"
        grass.z_index = 10
        $%Ground.add_child(grass)
    else:
        var grass = $%Ground.get_node_or_null("Grass")
        if grass:
            grass.queue_free()

@tool

extends Node

@export var mask_size: Vector2i = Vector2i(64, 64)
@export var masks: int = 8

@export var cycle_random: bool = true
@export var cycle_time: float = 0.2

@export_tool_button("Regenerate Masks")
var generate_mask = _generate_mask

const MASKS_PATH: String = "res://graphics/cropMask/masks/"

var _time_accumulator: float = 0.0
func _process(delta: float) -> void:
    if cycle_random:
        _time_accumulator += delta
        if _time_accumulator >= cycle_time:
            _time_accumulator = 0.0
            $%Material.material.set_shader_parameter("seed", randi() % 100000)

func _generate_mask() -> void:
    # Delete masks
    var dir = DirAccess.open(MASKS_PATH)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir():
                dir.remove(file_name)
            file_name = dir.get_next()
        dir.list_dir_end()
    else:
        DirAccess.make_dir_recursive_absolute(MASKS_PATH)

    # Reset sizes
    $SubViewport.size = mask_size
    $%Material.custom_minimum_size = mask_size
    $%Material.size = mask_size

    for child in $TexturePreviews.get_children():
        child.queue_free()

    # Generate new masks
    for i in masks:
        $%Material.material.set_shader_parameter("seed", randi() % 100000)
        await get_tree().process_frame  # Wait a frame for shader to update
        var image = ($ViewportPreview.texture as ViewportTexture).get_image()
        var path = "%smask_%d.png" % [MASKS_PATH, i]
        image.save_png(path)

    # Wait for asset reimport
    while ResourceLoader.exists("%smask_0.png" % MASKS_PATH) == false:
        await get_tree().process_frame

    for i in masks:
        var path = "%smask_%d.png" % [MASKS_PATH, i]
        var preview = TextureRect.new()
        preview.custom_minimum_size = mask_size
        preview.name = "Mask %d" % i
        preview.texture = load(path) as Texture2D
        $TexturePreviews.add_child(preview)

@tool

extends ColorRect

@export
var textures: Array[Texture2D] = []

@export_tool_button("Generate texture array")
var generate_textures = _generate_textures

func _generate_textures() -> void:
    var arr = Texture2DArray.new()
    arr.create_from_images(textures.map(func(t: Texture2D) -> Image:
        return t.get_image()
    ))
    material.set_shader_parameter("icon_tex", arr)

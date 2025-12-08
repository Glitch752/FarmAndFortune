@tool

extends Polygon2D

@onready var chunk: Node2D = $".."

const FOAM_TEXTURE_SIZE: int = 32
const FOAM_TEXTURE_GENERATION_MARGIN: int = 1

func _ready() -> void:
    material = material.duplicate()
    (material as ShaderMaterial).set_shader_parameter("UV_OFFSET", chunk.chunk_position)

    var foam_image = generate_foam_texture()
    var foam_texture = ImageTexture.create_from_image(foam_image)
    (material as ShaderMaterial).set_shader_parameter("FOAM_TEXTURE", foam_texture)
    (material as ShaderMaterial).set_shader_parameter("FOAM_TEXTURE_MARGIN", FOAM_TEXTURE_GENERATION_MARGIN / float(FOAM_TEXTURE_SIZE))


func generate_foam_texture(size: int = FOAM_TEXTURE_SIZE, blur_radius: int = 1) -> Image:
    var generation_size = size + FOAM_TEXTURE_GENERATION_MARGIN * 2;
    var foam_image = Image.create(generation_size, generation_size, false, Image.FORMAT_R8)

    # set pixels to white where there is grass
    for y in generation_size:
        for x in generation_size:
            var world_pos = Vector2(
                # why is this over 2? uhh... your guess is as good as mine.
                # it makes it look better though!
                x - FOAM_TEXTURE_GENERATION_MARGIN / 2.0,
                y - FOAM_TEXTURE_GENERATION_MARGIN / 2.0
            ) * (chunk.size / float(size)) + chunk.position
            if MapSingleton.check_grass_at_position(world_pos):
                foam_image.set_pixel(x, y, Color.WHITE)
            else:
                foam_image.set_pixel(x, y, Color.BLACK)

    # blur outward (simple box blur)
    for i in blur_radius:
        foam_image = _blur_image(foam_image)

    return foam_image

func _blur_image(image: Image) -> Image:
    var size = image.get_size()
    var blurred = Image.create(size.x, size.y, false, Image.FORMAT_R8)
    
    for y in size.y:
        for x in size.x:
            var sum = 0.0
            var count = 0
            for dy in [-1, 0, 1]:
                for dx in [-1, 0, 1]:
                    var nx = x + dx
                    var ny = y + dy
                    if nx >= 0 and nx < size.x and ny >= 0 and ny < size.y:
                        sum += image.get_pixel(nx, ny).r
                        count += 1
            blurred.set_pixel(x, y, Color(sum / count, 0, 0, 1))
    
    return blurred



@export_tool_button("Create 3D noise texture")
@warning_ignore("unused_private_class_variable")
var _create_noise_texture_button = _create_noise_texture

func _create_noise_texture():
    print("what")

    var source_spritesheet: Image = load("res://world/chunks/water/worley_spritesheet.png").get_image()
    var size = int(round(pow(source_spritesheet.get_size().x, 2./3.)))

    print(size)
    var large_grid_size = int(ceil(sqrt(size)))

    var layers: Array[Image] = []
    # The spritesheet is a size x size grid of (size x size) images representing layers,
    # going top left to bottom right.
    for z in size:
        print("Creating layer %d" % z)

        var layer_image = Image.create(size, size, false, Image.FORMAT_R8)

        var spritesheet_x = z % large_grid_size
        var spritesheet_y = floor(z / float(large_grid_size))

        for y in size:
            for x in size:
                var px = spritesheet_x * size + x
                var py = spritesheet_y * size + y

                if px > source_spritesheet.get_size().x or py > source_spritesheet.get_size().y:
                    print("Out of bounds: %d, %d" % [px, py])
                    return

                var pixel_color = source_spritesheet.get_pixel(px, py)
                layer_image.set_pixel(x, y, pixel_color)

        layers.append(layer_image)

        # Yield to allow the editor to update
        await get_tree().process_frame

        print("Layer %d done" % z)

    print("Creating 3D texture")

    var noise_texture = ImageTexture3D.new()
    noise_texture.create(Image.FORMAT_R8, size, size, size, false, layers)

    print("Saving texture")

    # Save the noise texture to a resource file, maybe?
    ResourceSaver.save(noise_texture, "res://world/chunks/water/water_noise_texture.res")

    print("Done")

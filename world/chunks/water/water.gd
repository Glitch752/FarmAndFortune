@tool

extends Polygon2D

@export_tool_button("Create 3D noise texture")
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

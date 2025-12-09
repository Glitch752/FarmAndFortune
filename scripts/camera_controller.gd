extends Camera2D

var speed = 250 # pixels per second

func _process(delta):
    var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    if input_vector.length() > 0:
        input_vector = input_vector.normalized()

    position += input_vector * speed * delta

    # Clamp the position to the limits
    var world_view_size = get_viewport_rect().size / zoom
    position.x = clamp(
        position.x,
        limit_left + world_view_size.x / 2,
        limit_right - world_view_size.x / 2
    )
    position.y = clamp(
        position.y,
        limit_top + world_view_size.y / 2,
        limit_bottom - world_view_size.y / 2
    )

    # TODO: If the camera is entirely over locked chunks,
    # add a keybind and control hint to reset its position

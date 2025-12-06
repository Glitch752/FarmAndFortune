extends Camera2D

var speed = 400 # pixels per second
var velocity = Vector2.ZERO
var acceleration = 800 # pixels per second squared

func _process(delta):
    var input_vector = Input.get_vector("ui_down", "ui_up", "ui_left", "ui_right")

    if input_vector.length() > 0:
        input_vector = input_vector.normalized()

    velocity.move_toward(input_vector * speed, acceleration * delta)
    position += velocity * delta


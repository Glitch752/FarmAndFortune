extends Camera2D

var speed = 250 # pixels per second
var velocity = Vector2.ZERO
var acceleration = 2500 # pixels per second squared

func _process(delta):
    var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    if input_vector.length() > 0:
        input_vector = input_vector.normalized()

    velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
    position += velocity * delta

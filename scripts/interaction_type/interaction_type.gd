class_name InteractionType extends Resource

var color: Color = Color.WHITE

## Only should be called on unlocked tiles.
func interact(_tile: Vector2i) -> void:
    push_error("interact() not implemented for this InteractionType")
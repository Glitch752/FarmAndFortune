class_name InteractionType extends Resource

var color: Color = Color.WHITE

var duration: float = 0.05

## Only should be called on unlocked tiles and after can_interact() returns true.
func interact(_tile: Vector2i) -> void:
    push_error("interact() not implemented for this InteractionType")

## Only should be called on unlocked tiles.
func can_interact(_tile: Vector2i) -> bool:
    push_error("can_interact() not implemented for this InteractionType")
    return false
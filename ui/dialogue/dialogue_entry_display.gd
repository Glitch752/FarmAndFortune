@tool

extends TransformContainer

@export var entry: DialogueEntry:
    set(value):
        entry = value
        _update_display()
    get:
        return entry

func _ready() -> void:
    _update_display()

func _update_display() -> void:
    pass
@tool

extends "res://world/crops/base_crop.gd"

@onready var carrot = $%Carrot

func _get_growth_stage_lengths() -> PackedFloat32Array:
    return PackedFloat32Array([1.0])

func _created():
    carrot.rotation_degrees = randi() % 20 - 10 - 45

    var brightness = randf_range(0.85, 1.0)
    carrot.self_modulate = Color(brightness, brightness, brightness)

func _render():
    carrot.position.y = get_stage_progress(0) * -5 + 22
    carrot.scale = Vector2.ONE * (0.5 + get_stage_progress(0) * 0.5) * 0.03

@tool

extends "res://world/crops/base_crop.gd"

@onready var plant = $%Plant
@onready var tomato1 = $%Tomato1
@onready var tomato2 = $%Tomato2

func _get_growth_stage_lengths() -> PackedFloat32Array:
    return PackedFloat32Array([0.6, 0.4])

func _render():
    plant.position.y = get_stage_progress(0) * -5 + 25
    plant.scale = Vector2.ONE * (0.5 + get_stage_progress(0) * 0.5) * 0.03

    tomato1.scale = Vector2.ONE * 0.012 * get_stage_progress(1)
    tomato2.scale = Vector2.ONE * 0.013 * get_stage_progress(1)

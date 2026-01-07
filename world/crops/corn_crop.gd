@tool

extends "res://world/crops/base_crop.gd"

@onready var stem = $%Stem
@onready var corn1 = $%Corn1
@onready var corn2 = $%Corn2

func _get_growth_stage_lengths() -> PackedFloat32Array:
    return PackedFloat32Array([0.6, 0.4])

func _render():
    stem.position.y = get_stage_progress(0) * -9 + 25
    stem.scale = Vector2.ONE * (0.5 + get_stage_progress(0) * 0.5) * 0.03

    corn1.scale = Vector2.ONE * 0.012 * get_stage_progress(1)
    corn2.scale = Vector2.ONE * 0.013 * get_stage_progress(1)

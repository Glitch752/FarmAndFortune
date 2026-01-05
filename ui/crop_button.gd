@tool

extends "res://ui/tool_button.gd"

@export var crop: CropData

func _ready():
    tool_name = crop.name
    tool_icon = crop.icon
    interaction = PlantInteraction.new(crop.id)

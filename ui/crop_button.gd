@tool

extends "res://ui/tool_button.gd"

@export var crop: CropData
@export var item: ItemData

func _ready():
    if not crop:
        return
    
    tool_name = crop.name
    tool_icon = crop.icon
    interaction = PlantInteraction.new(crop.id, item.id)

@tool

extends "res://ui/blur_button.gd"

@export var shop_ui: NodePath

func _ready():
    super._ready()
    
    if Engine.is_editor_hint():
        return
    
    pressed.connect(func():
        if shop_ui:
            var shop_ui_node = get_node(shop_ui)
            if shop_ui_node:
                shop_ui_node.toggle_open()
    )

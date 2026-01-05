@tool

extends "res://ui/blur_button.gd"

func _ready():
    super._ready()
    
    pressed.connect(func():
        get_parent().select()
    )

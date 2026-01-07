@tool

extends StackContainer

@onready var label = $%Label

@export var text: String:
    set(value):
        text = value
        if label:
            label.text = value

signal pressed

func _ready():
    $%Button.pressed.connect(pressed.emit)
    label.text = text

extends PanelContainer

@export var normal_style: StyleBox
@export var hover_style: StyleBox
@export var press_style: StyleBox

@onready var button: Button = $Button

func _ready():
    button.connect("mouse_entered", _update_style)
    button.connect("mouse_exited", _update_style)
    button.connect("pressed", _update_style)
    button.connect("released", _update_style)
    _update_style()

func _update_style():
    var style: StyleBox
    if button.pressed:
        style = press_style
    elif button.is_hovered():
        style = hover_style
    else:
        style = normal_style
    add_theme_stylebox_override("panel", style)
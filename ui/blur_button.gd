@tool
extends PanelContainer

signal pressed()
signal released()

@export var icon: Texture2D:
    set(value):
        icon = value
        if button:
            button.icon = icon

@export_group("Theme overrides")
@export var normal_style: StyleBox
@export var hover_style: StyleBox
@export var press_style: StyleBox

@onready var button: Button = $Button

# we can't use button.is_hovered() since it updates at the wrong time,
# so we track this ourself.
var hovered: bool = false

func _ready():
    if icon:
        button.icon = icon

    button.connect("mouse_entered", func():
        hovered = true
        _update_style()
    )
    button.connect("mouse_exited", func():
        hovered = false
        _update_style()
    )
    button.connect("button_down", _update_style)
    button.connect("button_up", _update_style)
    _update_style()

    button.connect("button_down", pressed.emit)
    button.connect("button_up", released.emit)

func _update_style():
    var style: StyleBox
    if button.button_pressed:
        style = press_style
        print("press")
    elif hovered:
        style = hover_style
        print("hover")
    else:
        style = normal_style
        print("normal")
    add_theme_stylebox_override("panel", style)

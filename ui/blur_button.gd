@tool
extends PanelContainer

signal pressed()
signal released()

@export var icon: Texture2D:
    set(value):
        icon = value
        if button:
            button.icon = icon

@export var padding: int = 0:
    set(value):
        padding = value
        _update_padding()
@export var offset: Vector2 = Vector2.ZERO:
    set(value):
        offset = value
        _update_padding()

@export var button_size: int = 52:
    set(value):
        button_size = value
        _update_padding()

@export var disabled: bool = false:
    set(value):
        disabled = value
        if button:
            button.disabled = disabled

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
    
    if abs(offset.x) > padding or abs(offset.y) > padding:
        push_error("offset should not be larger than padding")

    if padding > 0 or button_size != 52:
        _update_padding()

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

## hack but whatever
var tooltip_override: String:
    set(value):
        tooltip_override = value
        tooltip_text = tooltip_override
        if button:
            button.tooltip_text = tooltip_override

var duplicated: bool = false

func _update_padding():
    if not button:
        return
    
    button.custom_minimum_size = Vector2.ONE * (button_size - padding * 2)

    if not duplicated:
        press_style = press_style.duplicate()
        hover_style = hover_style.duplicate()
        normal_style = normal_style.duplicate()
    
    var top_margin = padding + offset.y
    var bottom_margin = padding - offset.y
    var left_margin = padding + offset.x
    var right_margin = padding - offset.x

    var set_margins = func(style: StyleBox):
        style.content_margin_bottom = bottom_margin
        style.content_margin_top = top_margin
        style.content_margin_left = left_margin
        style.content_margin_right = right_margin
    
    set_margins.call(press_style)
    set_margins.call(hover_style)
    set_margins.call(normal_style)

    _update_style()

func _update_style():
    var style: StyleBox
    if disabled:
        style = normal_style
    elif button.button_pressed:
        style = press_style
    elif hovered:
        style = hover_style
    else:
        style = normal_style
    add_theme_stylebox_override("panel", style)

@tool

extends StackContainer

@onready var label = $%Label
@onready var button = $%Button
@onready var transform = $%TransformContainer

@export var inactive_label_color: Color = Color(1, 1, 1, 0.7):
    set(value):
        inactive_label_color = value
        if not active and label:
            label.modulate = value
@export var active_label_color: Color = Color(1, 1, 1, 1.0):
    set(value):
        active_label_color = value
        if active and label:
            label.modulate = value

@export var text: String:
    set(value):
        text = value
        if label:
            label.text = value

var active: bool = false:
    set(value):
        active = value
        var tween = create_tween()
        tween.set_trans(Tween.TRANS_CUBIC)
        tween.set_ease(Tween.EASE_OUT)
        if active:
            tween.tween_property(transform, "visual_position:x", 0.0, 0.2)
            tween.parallel().tween_property(label, "modulate", active_label_color, 0.2)
        else:
            tween.tween_property(transform, "visual_position:x", -30.0, 0.2)
            tween.parallel().tween_property(label, "modulate", inactive_label_color, 0.2)

signal pressed

func _ready():
    button.pressed.connect(pressed.emit)

    mouse_entered.connect(func():
        button.grab_focus()
    )
    mouse_exited.connect(func():
        button.release_focus()
    )

    button.focus_entered.connect(func():
        active = true
    )
    button.focus_exited.connect(func():
        active = false
    )
    
    label.text = text
    label.modulate = inactive_label_color

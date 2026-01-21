@tool

extends TransformContainer

@export
var shown: bool = false:
    set(value):
        shown = value
        
        if shown:
            self._shown()
        else:
            self._hidden()
    get:
        return shown

@export var transition_offset: Vector2 = Vector2(10, 0)
@export var transition_duration: float = 0.2

func _ready() -> void:
    if shown:
        visual_position = Vector2(0, 0)
        modulate.a = 1.0
        visible = true
    else:
        visual_position = transition_offset
        modulate.a = 0.0
        visible = false

var current_tween: Tween = null
func make_tween() -> Tween:
    if current_tween:
        current_tween.kill()
    
    current_tween = create_tween()
    current_tween.connect("finished", func() -> void:
        current_tween = null
    )
    return current_tween

func _shown() -> void:
    visible = true
    
    var tween = make_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "visual_position", Vector2(0, 0), transition_duration)
    tween.parallel().tween_property(self, "modulate:a", 1.0, transition_duration)

func _hidden() -> void:
    var tween = make_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "visual_position", transition_offset, transition_duration)
    tween.parallel().tween_property(self, "modulate:a", 0.0, transition_duration)
    tween.tween_callback(func() -> void:
        visible = false
    )

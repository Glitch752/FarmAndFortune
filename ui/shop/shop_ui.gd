@tool

extends TransformContainer

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    
    DialogueSingleton.dialogue_event_triggered.connect(func(event):
        if event == "win_game":
            _close()
    )

func _init() -> void:
    if Engine.is_editor_hint():
        return
    
    visible = false
    modulate.a = 0.0
    visual_position = Vector2(0, -10)

func _input(event: InputEvent) -> void:
    if Engine.is_editor_hint():
        return
    
    if not visible:
        return
    
    if event.is_action_pressed("ui_cancel"):
        _close()
        get_tree().set_input_as_handled()
        return

    # If we're open and this is a click outside of us, close
    if event is InputEventMouseButton:
        var mb_event: InputEventMouseButton = event
        if mb_event.pressed:
            if not get_rect().has_point(get_local_mouse_position()):
                _close()
                get_tree().set_input_as_handled()
                return

func toggle_open() -> void:
    if visible:
        _close()
    else:
        _open()

func _open() -> void:
    visible = true
    
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(self, "modulate:a", 1.0, 0.5)
    tween.parallel().tween_property(self, "visual_position:y", 0.0, 0.5)

func _close() -> void:
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)

    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.parallel().tween_property(self, "visual_position:y", -10.0, 0.5)
    
    await tween.finished
    visible = false

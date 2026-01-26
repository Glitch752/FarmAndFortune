@tool

extends TransformContainer

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    
    DialogueSingleton.dialogue_event_triggered.connect(func(event):
        if event == "win_game":
            _open()
    )

    $%KeepPlayingButton.pressed.connect(func():
        _close()
    )
    $%ExitButton.pressed.connect(func():
        SaveData.save()
        MapSingleton.unload()
        get_tree().change_scene_to_packed(preload("res://ui/Menu.tscn"))
    )

func _init() -> void:
    if Engine.is_editor_hint():
        return
    
    visible = false
    modulate.a = 0.0
    visual_position = Vector2(0, -10)

func _format_stats() -> String:
    return """Final time: [color=#88ee88]{play_time}[/color]
Gross earnings: [color=#88ee88]${gross_earnings}[/color]
Final balance: [color=#88ee88]${money}[/color]
Total crops harvested: [color=#88ee88]{total_crops_harvested}[/color]""".format({
        "play_time": SaveData.format_play_time(),
        "gross_earnings": InventorySingleton.format_money(InventorySingleton.gross_earnings),
        "money": InventorySingleton.format_money(InventorySingleton.money),
        "total_crops_harvested": SaveData.total_crops_harvested,
    })

func _open() -> void:
    $%FinalStats.text = _format_stats()

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

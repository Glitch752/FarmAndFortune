extends ColorRect

var tween: Tween = null

var paused = false:
    set(value):
        paused = value
        get_tree().paused = paused

        if paused:
            $%Stats.text = _format_stats()
        
        if tween != null:
            tween.kill()
            tween = null
        tween = create_tween()
        tween.set_trans(Tween.TRANS_CUBIC)
        tween.set_ease(Tween.EASE_IN_OUT)
        if paused:
            visible = true
            tween.tween_property(self, "modulate:a", 1.0, 0.3)
            $%ResumeButton.focus()
        else:
            tween.tween_property(self, "modulate:a", 0.0, 0.3)
            tween.tween_callback(func() -> void:
                visible = false
            )

func _ready() -> void:
    visible = false
    modulate.a = 0

    $%ResumeButton.pressed.connect(func() -> void:
        paused = false
    )
    $%SaveButton.pressed.connect(func() -> void:
        SaveData.save()
    )
    $%SaveAndQuitButton.pressed.connect(func() -> void:
        paused = false
        await get_tree().process_frame

        SaveData.save()
        MapSingleton.unload()
        get_tree().change_scene_to_packed(preload("res://ui/Menu.tscn"))
    )

func _format_stats() -> String:
    return """Current Save: [color=#88ee88]{save_name}[/color]
Character Name: [color=#88ee88]{character_name}[/color]
Play time: [color=#88ee88]{play_time}[/color]

Gross earnings: [color=#88ee88]${gross_earnings}[/color]
Money: [color=#88ee88]${money}[/color]

Total crops harvested: [color=#88ee88]{total_crops_harvested}[/color]""".format({
        "save_name": SaveData.loaded_save_name,
        "character_name": SaveData.character_name,
        "play_time": SaveData.format_play_time(),
        "gross_earnings": InventorySingleton.format_money(InventorySingleton.gross_earnings),
        "money": InventorySingleton.format_money(InventorySingleton.money),
        "total_crops_harvested": SaveData.total_crops_harvested,
    })

func _shortcut_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        paused = not paused
        get_viewport().set_input_as_handled()

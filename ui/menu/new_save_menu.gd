extends VBoxContainer

func _ready() -> void:
    $%CreateSave.pressed.connect(_create_save)

func _create_save() -> void:
    var save_name = $%NameInput.text.strip_edges()
    if save_name == "":
        # Shake the save name input to indicate error
        $%NameInput.add_color_override("font_color", Color.RED)
        var tween = get_tree().create_tween()
        for i in range(10):
            var offset = randf_range(-10, 10)
            tween.tween_property($%NameInput, "rect_position:x", $%NameInput.rect_position.x + offset, 0.05)
        await tween.finished
        $%NameInput.add_color_override("font_color", Color.WHITE)
        return
    
    var character_id = $%CharacterSelector.get_selected_character_id()
    SaveData.create_new_save(save_name, character_id)

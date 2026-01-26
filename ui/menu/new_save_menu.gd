extends VBoxContainer

func _ready() -> void:
    $%CreateSave.pressed.connect(_create_save)

@onready var save_name_input = $%SaveNameInput
@onready var character_name_input = $%CharacterNameInput

func _create_save() -> void:
    var failed = false

    var save_name = save_name_input.text.strip_edges()
    if save_name == "":
        _display_input_error(save_name_input)
        failed = true
    var character_name = character_name_input.text.strip_edges()
    if character_name == "":
        _display_input_error(character_name_input)
        failed = true

    if failed:
        return
    
    var character_id = $%CharacterSelector.get_selected_character_id()
    SaveData.create_new_save(save_name, character_name, character_id)

func _display_input_error(input_field: LineEdit) -> void:
    # Shake the save name input to indicate error
    var original_placeholder_color = input_field.get_theme_color("font_placeholder_color")
    input_field.add_theme_color_override("font_placeholder_color", Color.from_rgba8(220, 100, 100))
    var tween = get_tree().create_tween()
    for i in range(10):
        var offset = randf_range(-5, 5)
        tween.tween_property(input_field, "position:x", input_field.position.x + offset, 0.05)
    tween.tween_property(input_field, "position:x", input_field.position.x, 0.05)
    await tween.finished
    input_field.add_theme_color_override("font_placeholder_color", original_placeholder_color)

extends PanelContainer

var selected_category: String = CharacterSingleton.character_categories.keys()[0]
var selected_variant: int = 0

func _ready() -> void:
    $%PreviousCategory.pressed.connect(func():
        var categories = CharacterSingleton.character_categories.keys()
        var current_index = categories.find(selected_category)
        var previous_index = (current_index - 1 + categories.size()) % categories.size()
        selected_category = categories[previous_index]

        var variant_count = CharacterSingleton.character_categories[selected_category]
        if selected_variant > variant_count - 1:
            selected_variant = variant_count - 1

        _update_character_display()
    )

    $%NextCategory.pressed.connect(func():
        var categories = CharacterSingleton.character_categories.keys()
        var current_index = categories.find(selected_category)
        var next_index = (current_index + 1) % categories.size()
        selected_category = categories[next_index]

        var variant_count = CharacterSingleton.character_categories[selected_category]
        if selected_variant > variant_count - 1:
            selected_variant = variant_count - 1

        _update_character_display()
    )

    $%PreviousVariant.pressed.connect(func():
        var variant_count = CharacterSingleton.character_categories[selected_category]
        selected_variant = (selected_variant - 1 + variant_count) % variant_count
        _update_character_display()
    )

    $%NextVariant.pressed.connect(func():
        var variant_count = CharacterSingleton.character_categories[selected_category]
        selected_variant = (selected_variant + 1) % variant_count
        _update_character_display()
    )

func _update_character_display() -> void:
    var character_id = CharacterSingleton.get_character_id(selected_category, selected_variant)
    CharacterSingleton.character = character_id

    $%CategoryLabel.text = CharacterSingleton.format_category_name(selected_category)
    $%CharacterTexture.texture = load(CharacterSingleton.get_character_image())

func get_selected_character_id() -> StringName:
    return CharacterSingleton.get_character_id(selected_category, selected_variant)

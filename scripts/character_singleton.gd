extends Node

# category -> number of variants
var character_categories: Dictionary[String, int] = {
    "farmer": 6,
    "office_worker": 6,
    "factory_worker": 6,
    "health_worker": 6,
    "construction_worker": 6,
    "student": 6,
    "artist": 6
}

func format_category_name(category: StringName) -> String:
    return category.capitalize()

func get_character_id(category: StringName, variant: int) -> StringName:
    return &"%s_%d" % [category, variant + 1]

func get_character_image() -> String:
    return "res://art/characters/%s.png" % SaveData.character

var character: StringName:
    get:
        return SaveData.character
    set(value):
        var split = value.reverse().split("_", false, 1)
        var category = split[1].reverse() if split.size() == 2 else "farmer"
        var variant_str = split[0].reverse() if split.size() == 2 else "1"
        var variant = int(variant_str) - 1
        if not character_categories.has(category):
            push_error("Invalid character category: %s" % category)
            value = "farmer_1"
        elif variant < 0 or variant >= character_categories[category]:
            push_error("Invalid character variant: %d for category %s" % [variant + 1, category])
            value = "farmer_1"
        
        SaveData.character = value

func _init() -> void:
    pass
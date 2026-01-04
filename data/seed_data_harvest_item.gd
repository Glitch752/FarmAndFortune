class_name SeedData_HarvestItem extends Resource

enum ItemType {
    Seed,
    Item
}
@export var item_type: ItemType

var item_id: StringName
@export var quantity: int = 1

# Only show item_id if item_type is Seed
func _get_property_list() -> Array:
    var properties = []
    if item_type == ItemType.Seed: # Seed
        properties.append({
            "name": "item_id",
            "type": TYPE_STRING_NAME,
            "usage": PROPERTY_USAGE_DEFAULT
        })
    return properties
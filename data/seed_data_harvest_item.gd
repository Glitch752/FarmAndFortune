class_name SeedData_HarvestItem extends Resource

@export_enum("Seed", "Money") var item_type: int

@export var item_id: StringName
@export var quantity: int = 1

# Only show item_id if item_type is Seed
func _get_property_list() -> Array:
    var properties = super.get_property_list()
    if item_type != 0: # Seed
        properties = properties.filter(func(p):
            return p["name"] != "item_id"
        )
    return properties
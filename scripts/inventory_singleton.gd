extends Node

signal inventory_changed()

@warning_ignore("unused_signal")
signal item_selected(item: ItemData)

var items: Dictionary[StringName, int]:
    get:
        return SaveData.inventory
    set(value):
        SaveData.inventory = value

func add_item(item_id: StringName, quantity: int = 1) -> void:
    if items.has(item_id):
        items[item_id] += quantity
    else:
        items[item_id] = quantity
    inventory_changed.emit()

func remove_item(item_id: StringName, quantity: int = 1) -> bool:
    if items.has(item_id):
        var current_quantity = items[item_id]
        if current_quantity >= quantity:
            items[item_id] = max(0, items[item_id] - quantity)
            inventory_changed.emit()
            return true
        return false
    return false

func get_item_quantity(item_id: StringName) -> int:
    return items.get(item_id, 0)

func has_item(item_id: StringName, quantity: int = 1) -> bool:
    return get_item_quantity(item_id) >= quantity

## Returns all items with quantity > 0
func get_all_items() -> Array[StringName]:
    var result: Array[StringName] = []
    for item_id in items.keys():
        if items[item_id] > 0:
            result.append(item_id)
    return result
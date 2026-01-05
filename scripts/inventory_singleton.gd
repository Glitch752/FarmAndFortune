extends Node

signal inventory_changed

var items: Dictionary[StringName, int] = {}

func add_item(item_id: StringName, quantity: int = 1) -> void:
    if items.has(item_id):
        items[item_id] += quantity
    else:
        items[item_id] = quantity
    emit_signal("inventory_changed")

func remove_item(item_id: StringName, quantity: int = 1) -> bool:
    if items.has(item_id):
        var current_quantity = items[item_id]
        if current_quantity >= quantity:
            items[item_id] = max(0, items[item_id] - quantity)
            emit_signal("inventory_changed")
            return true
        return false
    return false

func get_item_quantity(item_id: StringName) -> int:
    return items.get(item_id, 0)

func has_item(item_id: StringName, quantity: int = 1) -> bool:
    return get_item_quantity(item_id) >= quantity

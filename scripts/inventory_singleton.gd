extends Node

signal inventory_changed()

@warning_ignore("unused_signal")
signal item_selected(item: ItemData)

var items: Dictionary[StringName, int]:
    get:
        return SaveData.inventory
    set(value):
        SaveData.inventory = value

signal money_changed(new_amount: int)

## Eh, close enough to an inventory item
var money: int:
    get:
        return SaveData.money
    set(value):
        SaveData.money = value
        money_changed.emit(money)

var gross_earnings: int:
    get:
        return SaveData.gross_earnings
    set(value):
        SaveData.gross_earnings = value

func earn_money(amount: int) -> void:
    money += amount
    gross_earnings += amount

func has_money(amount: int) -> bool:
    return money >= amount

func spend_money(amount: int) -> bool:
    if money >= amount:
        money -= amount
        return true
    return false

func format_money(amount: int) -> String:
    # Format as X,XXX
    var abs_amount = abs(amount)
    var v = ""
    while abs_amount >= 1000:
        var chunk = abs_amount % 1000
        v = ",%03d%s" % [chunk, v]
        abs_amount /= 1000
    v = "%d%s" % [abs_amount, v]
    if amount < 0:
        v = "-%s" % v
    return v

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
extends Control

## Note: this doesn't update when its parameters change after _ready.
## Usually I would implement that, but we re-create these buttons
## every time the inventory changes anyway.

@export var item: ItemData
@export var quantity: int = 1

func _ready() -> void:
    if item == null:
        push_error("InventoryItemUI instantiated with null item data")
        return
    
    tooltip_text = "%s x%d\n\n%s" % [item.name, quantity, item.description]
    $%Button.icon = item.icon
    $%Button.tooltip_override = tooltip_text
    $%Quantity.text = str(quantity)
    
    $%Button.disabled = item.crop == null

func select() -> void:
    InventorySingleton.item_selected.emit(item)

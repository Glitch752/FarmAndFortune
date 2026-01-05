extends VBoxContainer

func _ready() -> void:
    update_items()
    InventorySingleton.inventory_changed.connect(update_items)

func update_items() -> void:
    # Clear existing items
    for child in get_children():
        child.queue_free()
    
    # Add an InventoryItem for each item in the inventory
    for item_id in InventorySingleton.items.keys():
        var item_data = DataLoader.items[item_id]
        var quantity = InventorySingleton.get_item_quantity(item_id)
        
        if quantity > 0:
            var item_button = preload("res://ui/inventory/InventoryItem.tscn").instantiate()
            item_button.item = item_data
            item_button.quantity = quantity
            add_child(item_button)

class_name HarvestInteraction extends InteractionType

func _init() -> void:
    color = Color(0.5, 0.5, 1)

func can_interact(tile: Vector2i) -> bool:
    var crop = MapSingleton.get_crop_at(tile)
    if crop == null:
        return false
    if not crop.is_fully_grown():
        return false
    return true

func interact(tile: Vector2i) -> void:
    var crop = MapSingleton.get_crop_at(tile)
    if crop == null:
        return
    var harvest_items = crop.crop.harvest_items
    for item in harvest_items:
        InventorySingleton.add_item(item.item_id, item.quantity)
    MapSingleton.set_crop_at(tile, null)
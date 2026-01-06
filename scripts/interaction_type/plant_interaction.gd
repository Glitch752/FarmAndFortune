class_name PlantInteraction extends InteractionType

var crop_id: StringName
var item_id: StringName

func _init(_crop_id: StringName, _item_id: StringName):
    crop_id = _crop_id
    item_id = _item_id
    
    color = Color(0.5, 1, 0.5)

func interact(tile: Vector2i) -> void:
    if MapSingleton.get_terrain_at(tile) != MapSingleton.TerrainType.SOIL:
        # TODO: juice - feedback for invalid planting
        return
    if MapSingleton.get_crop_at(tile) != null:
        # TODO: juice - feedback for invalid planting
        return
    
    if not InventorySingleton.remove_item(item_id, 1):
        # TODO: juice - feedback for not enough items
        return

    MapSingleton.set_crop_at(tile, WorldCrop.new(DataLoader.crops[crop_id]))

class_name PlantInteraction extends InteractionType

var crop_id: StringName
var item_id: StringName

func _init(_crop_id: StringName, _item_id: StringName):
    crop_id = _crop_id
    item_id = _item_id
    
    color = Color(0.5, 1, 0.5)


func can_interact(tile: Vector2i) -> bool:
    if MapSingleton.get_terrain_at(tile) != MapSingleton.TerrainType.SOIL:
        return false
    if MapSingleton.get_crop_at(tile) != null:
        return false
    if not InventorySingleton.has_item(item_id, 1):
        return false
    return true

func interact(tile: Vector2i) -> void:
    MapSingleton.set_crop_at(tile, WorldCrop.new(DataLoader.crops[crop_id]))
    InventorySingleton.remove_item(item_id, 1)

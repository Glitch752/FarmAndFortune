class_name DigInteraction extends InteractionType

func _init() -> void:
    color = Color(1, 0.5, 0.5)

func can_interact(tile: Vector2i) -> bool:
    if MapSingleton.get_terrain_at(tile) != MapSingleton.TerrainType.GRASS:
        return false
    return true

func interact(tile: Vector2i) -> void:
    MapSingleton.set_terrain_at(tile, MapSingleton.TerrainType.SOIL)
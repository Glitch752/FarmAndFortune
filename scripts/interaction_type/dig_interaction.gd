class_name DigInteraction extends InteractionType

func _init() -> void:
    color = Color(1, 0.5, 0.5)

func interact(tile: Vector2i) -> void:
    if MapSingleton.get_terrain_at(tile) == MapSingleton.TerrainType.GRASS:
        MapSingleton.set_terrain_at(tile, MapSingleton.TerrainType.SOIL)
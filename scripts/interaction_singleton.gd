extends Node

signal highlight_changed(new_tile: Vector2i)
var highlighted_tile: Vector2i = Vector2i.ZERO:
    set(tile):
        highlighted_tile = tile
        highlight_changed.emit(tile)

signal interaction_changed(current_interaction: InteractionType)
var current_interaction: InteractionType = DigInteraction.new():
    set(value):
        current_interaction = value
        interaction_changed.emit(current_interaction)

func interact():
    if not MapSingleton.get_chunk_at_tile(highlighted_tile).unlocked:
        return

    if current_interaction is DigInteraction:
        dig_at_tile(highlighted_tile)
    elif current_interaction is PlantInteraction:
        plant_at_tile(highlighted_tile)
    elif current_interaction is HarvestInteraction:
        harvest_at_tile(highlighted_tile)

func dig_at_tile(tile: Vector2i) -> void:
    if MapSingleton.get_terrain_at(tile) == MapSingleton.TerrainType.GRASS:
        MapSingleton.set_terrain_at(tile, MapSingleton.TerrainType.SOIL)

func plant_at_tile(tile: Vector2i) -> void:
    pass
func harvest_at_tile(tile: Vector2i) -> void:
    pass

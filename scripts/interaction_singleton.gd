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

    current_interaction.interact(highlighted_tile)

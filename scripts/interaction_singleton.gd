extends Node

enum InteractionType {
    Dig,
    Plant,
    Harvest
}

var interaction_shortcuts: Dictionary[Key, InteractionType] = {
    Key.KEY_1: InteractionType.Dig,
    Key.KEY_2: InteractionType.Plant,
    Key.KEY_3: InteractionType.Harvest
}

signal highlight_changed(new_tile: Vector2i)
var highlighted_tile: Vector2i = Vector2i.ZERO:
    set(tile):
        highlighted_tile = tile
        highlight_changed.emit(tile)

signal interaction_changed(current_interaction: InteractionType)
var current_interaction: InteractionType = InteractionType.Dig:
    set(value):
        current_interaction = value
        interaction_changed.emit(current_interaction)

func cycle(slots: int) -> void:
    current_interaction = (
        (int(current_interaction) + slots + InteractionType.size()) % InteractionType.size()
    ) as InteractionType

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("cycle_active_forward"):
        cycle(1)
        get_viewport().set_input_as_handled()
        return
    if event.is_action_pressed("cycle_active_backward"):
        cycle(-1)
        get_viewport().set_input_as_handled()
        return
    
    if event is InputEventKey and event.pressed and not event.echo:
        var key_event = event as InputEventKey
        var key = key_event.keycode
        if key in interaction_shortcuts:
            current_interaction = interaction_shortcuts[key]
            get_viewport().set_input_as_handled()
            return

    # Scrolling changes slots
    if event is InputEventMouseButton and event.pressed:
        _debounced_scroll.call([event as InputEventMouseButton])

var _debounced_scroll = preload("res://scripts/utils.gd").debounce(_scroll_input, 0.2)

func _scroll_input(event: InputEventMouseButton):
    if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
        cycle(1)
        get_viewport().set_input_as_handled()
        return
    elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
        cycle(-1)
        get_viewport().set_input_as_handled()
        return

func interact():
    match current_interaction:
        InteractionType.Dig:
            dig_at_tile(highlighted_tile)
        InteractionType.Plant:
            plant_at_tile(highlighted_tile)
        InteractionType.Harvest:
            harvest_at_tile(highlighted_tile)

func dig_at_tile(tile: Vector2i) -> void:
    if MapSingleton.get_terrain_at(tile) == MapSingleton.TerrainType.GRASS:
        MapSingleton.set_terrain_at(tile, MapSingleton.TerrainType.SOIL)

func plant_at_tile(tile: Vector2i) -> void:
    pass
func harvest_at_tile(tile: Vector2i) -> void:
    pass

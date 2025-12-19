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

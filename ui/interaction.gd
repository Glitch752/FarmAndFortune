extends Node2D

@onready var highlight = $%InteractionHighlight

var highlighted_tile: Vector2i = Vector2i.ZERO:
    set(tile):
        highlighted_tile = tile
        InteractionSingleton.highlighted_tile = tile
        interp_highlight()
var highlight_color: Color:
    set(value):
        highlight_color = value
        interp_highlight()

func interp_highlight():
    highlight.interp_to(MapSingleton.tile_to_world_position(highlighted_tile), highlight_color)

func _ready() -> void:
    InteractionSingleton.interaction_changed.connect(_on_interaction_changed)
    _on_interaction_changed(InteractionSingleton.current_interaction)

func _on_interaction_changed(current_interaction: InteractionSingleton.InteractionType) -> void:
    match current_interaction:
        InteractionSingleton.InteractionType.Dig:
            highlight_color = Color(1, 0.5, 0.5)
        InteractionSingleton.InteractionType.Plant:
            highlight_color = Color(0.5, 1, 0.5)
        InteractionSingleton.InteractionType.Harvest:
            highlight_color = Color(0.5, 0.5, 1)
    
func _process(_d) -> void:
    var pos = get_viewport().get_camera_2d().get_global_mouse_position()
    highlighted_tile = MapSingleton.world_to_tile_position(pos)

    if Input.is_action_pressed("interact"):
        InteractionSingleton.interact()
        get_viewport().set_input_as_handled()

extends Node2D

const slight_ease = preload("res://scripts/utils.gd").slight_ease;

@onready var highlight = $%InteractionHighlight
@onready var progress_bar = $%ProgressBar

var highlighted_tile: Vector2i = Vector2i.ZERO:
    set(tile):
        if tile != highlighted_tile:
            highlighted_tile = tile
            InteractionSingleton.highlighted_tile = tile
            interp_highlight()

            interacting = Input.is_action_pressed("interact")
            interact_progress = 0.0

var highlight_color: Color:
    set(value):
        highlight_color = value
        interp_highlight()

func interp_highlight():
    highlight.interp_to(MapSingleton.tile_to_world_position(highlighted_tile), highlight_color)

func _ready() -> void:
    InteractionSingleton.interaction_changed.connect(_on_interaction_changed)
    _on_interaction_changed(InteractionSingleton.current_interaction)

    progress_bar.visible = false

func _on_interaction_changed(current_interaction: InteractionType) -> void:
    highlight_color = current_interaction.color

var interact_progress: float = 0.0
var interacting: bool = false

func _process(delta: float) -> void:
    var pos = get_viewport().get_camera_2d().get_global_mouse_position()
    highlighted_tile = MapSingleton.world_to_tile_position(pos)

    var required_time = InteractionSingleton.current_interaction.duration

    $%LandPurchase.visible = false
    if not InteractionSingleton.can_interact():
        interacting = false
        interact_progress = 0.0
        progress_bar.visible = false

        if InteractionSingleton.is_locked() and InventorySingleton.has_item(&"land_deed"):
            $%LandPurchase.visible = true

            if Input.is_action_just_pressed("interact"):
                MapSingleton.get_chunk_at_tile(highlighted_tile).unlocked = true
                InventorySingleton.remove_item(&"land_deed", 1)
                get_viewport().set_input_as_handled()
        return

    if Input.is_action_just_pressed("interact"):
        interact_progress = 0.0
        interacting = true
        get_viewport().set_input_as_handled()
    elif Input.is_action_just_released("interact"):
        interact_progress = 0.0
        interacting = false
        get_viewport().set_input_as_handled()

    if interacting:
        interact_progress += delta
        progress_bar.value = slight_ease.call(interact_progress / required_time)
        if interact_progress >= required_time:
            InteractionSingleton.interact()
            interacting = false
    else:
        interact_progress = 0.0
    
    progress_bar.visible = interacting
    progress_bar.get_theme_stylebox("fill").bg_color = InteractionSingleton.current_interaction.color

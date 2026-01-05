@warning_ignore("missing_tool")

extends SelectionHighlightVBox

func _ready() -> void:
    selected_index = 0
    selected_index_changed.connect(_on_selected_index_changed)

    # Make all existing children internal so we only modify added ones
    for child in get_children():
        remove_child(child)
        add_child(child, true, INTERNAL_MODE_FRONT)
    
    InventorySingleton.inventory_changed.connect(update_seed_buttons)
    update_seed_buttons()

func update_seed_buttons() -> void:
    # Remove all existing seed buttons
    for child in get_children():
        child.queue_free()

    # Add a button for each seed in the inventory
    for item_id in InventorySingleton.items.keys():
        var item_data = DataLoader.items[item_id]
        var crop = item_data.crop

        if crop != null:
            var button = preload("res://ui/CropButton.tscn").instantiate()
            button.tool_name = crop.name
            button.tool_icon = crop.icon
            button.crop = crop
            button.item = item_data
            add_child(button)

func _on_selected_index_changed(new_index: int) -> void:
    InteractionSingleton.current_interaction = get_child(new_index, true).get_interaction_type()

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
        if key >= Key.KEY_1 and key <= Key.KEY_9:
            selected_index = (key - Key.KEY_1) % get_child_count(true)
            get_viewport().set_input_as_handled()
            return

    # Scrolling changes slots
    if event is InputEventMouseButton and event.pressed:
        _debounced_scroll.call([event as InputEventMouseButton])

var _debounced_scroll = preload("res://scripts/utils.gd").debounce(_scroll_input, 0.2)

func _scroll_input(event: InputEventMouseButton):
    if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
        cycle(1)
        get_viewport().set_input_as_handled()
        return
    elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
        cycle(-1)
        get_viewport().set_input_as_handled()
        return

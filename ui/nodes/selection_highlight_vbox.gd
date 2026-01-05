@tool

## Acts like a regular vbox container, but has a selected element index and
## centers the selected element.

extends Container

class_name SelectionHighlightVBox

signal selected_index_changed(new_index: int)

@export_range(0, 100, 1, "or_greater")
var selected_index: int = 0:
    set(value):
        selected_index = value
        selected_index_changed.emit(selected_index)
        
        var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
        tween.tween_property(self, "_selected_index", selected_index, 0.2)

func cycle(slots: int) -> void:
    selected_index = (
        (selected_index + slots + get_child_count(true)) % get_child_count(true)
    )

func select(node: Control) -> void:
    var index = get_children(true).find(node)
    if index != -1:
        selected_index = index

@export_range(0, 100, 0.1, "or_greater")
var x_offset: float = 10.0:
    set(value):
        x_offset = value
        queue_sort()

@export var active_color: Color = Color(1, 1, 1, 1):
    set(value):
        active_color = value
        queue_sort()
@export var inactive_color: Color = Color(0.5, 0.5, 0.5, 1):
    set(value):
        inactive_color = value
        queue_sort()

## A tweened version of selected_index for smooth scrolling.
## This doesn't need to be an integer!
## Intermediate numbers smoothly transition from one item to the next.
var _selected_index: float = 0:
    set(value):
        _selected_index = value
        queue_sort()

func _notification(what: int):
    match what: 
        NOTIFICATION_SORT_CHILDREN:
            _sort_children()

func _sort_children():
    var y_offset = 0.0
    
    var selection_fraction = _selected_index - floor(_selected_index)
    var selected_index_prev_y = 0.0
    var selected_index_next_y = 0.0

    for i in range(get_child_count(true)):
        var c = get_child(i, true)
        if c is Control:
            if not c.visible:
                continue
            
            var distance_to_selection = abs(i - _selected_index)
            var intensity = clamp(1.0 - distance_to_selection / 1.1, 0.0, 1.0)

            fit_child_in_rect(c, Rect2(Vector2(intensity * x_offset, 0), c.get_combined_minimum_size()))
            c.position.y = y_offset

            # Color based on intensity
            var color = inactive_color.lerp(active_color, intensity)
            c.color = color

            if i == floor(_selected_index):
                selected_index_prev_y = y_offset + c.size.y / 2.0
            if i == ceil(_selected_index):
                selected_index_next_y = y_offset + c.size.y / 2.0

            y_offset += c.size.y + get_theme_constant("separation")
    
    var selected_child_y = lerp(selected_index_prev_y, selected_index_next_y, selection_fraction)

    # Center selected child
    var container_center_y = size.y / 2.0
    var offset = container_center_y - selected_child_y
    for i in range(get_child_count(true)):
        var c = get_child(i, true)
        if c is Control:
            c.position.y += offset

func _get_minimum_size() -> Vector2:
    var total_height = 0.0
    var max_width = 0.0
    for c in get_children():
        if c is Control:
            var child_size = c.get_combined_minimum_size()
            total_height += child_size.y + get_theme_constant("separation")
            max_width = max(max_width, child_size.x)
    if get_child_count() > 0:
        total_height -= get_theme_constant("separation") # Remove last separation
    return Vector2(max_width, total_height)

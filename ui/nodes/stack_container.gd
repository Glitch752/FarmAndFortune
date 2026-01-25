@tool

## A container that makes all of its children take up its full size (or center or whatever based on size flags)
## and inherits the size of its largest child
## I'm not sure why this isn't in Godot by default, since I need it all the time...

extends Container

class_name StackContainer

enum EditorPreviewType {
    STACK,
    VERTICAL_BOX,
    HORIZONTAL_BOX
}

@export var editor_preview: EditorPreviewType = EditorPreviewType.STACK:
    set(value):
        editor_preview = value
        queue_sort()

func _notification(what):
    match what: 
        NOTIFICATION_SORT_CHILDREN:
            _sort_children()

func _sort_children():
    var preview = editor_preview if Engine.is_editor_hint() else EditorPreviewType.STACK
    if preview == EditorPreviewType.VERTICAL_BOX:
        var y_offset = 0.0
        for child in get_children():
            if child is Control:
                var child_size = Vector2(size.x, child.get_combined_minimum_size().y)
                fit_child_in_rect(child, Rect2(Vector2(0, y_offset), child_size))
                y_offset += child_size.y + 5.0
    elif preview == EditorPreviewType.HORIZONTAL_BOX:
        var x_offset = 0.0
        for child in get_children():
            if child is Control:
                var child_size = Vector2(child.get_combined_minimum_size().x, size.y)
                fit_child_in_rect(child, Rect2(Vector2(x_offset, 0), child_size))
                x_offset += child_size.x + 5.0
    else:
        for child in get_children():
            if child is Control:
                fit_child_in_rect(child, Rect2(Vector2.ZERO, size))

func _get_minimum_size():
    var max_size = Vector2.ZERO
    for child in get_children():
        if child is Control:
            var child_min_size = child.get_combined_minimum_size()
            max_size.x = max(max_size.x, child_min_size.x)
            max_size.y = max(max_size.y, child_min_size.y)
    return max_size

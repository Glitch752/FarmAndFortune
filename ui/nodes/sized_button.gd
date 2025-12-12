@tool

extends Button

class_name SizedButton

## A button that inherits the size of its largest child so one can
## actually do layouts inside of buttons

## This probably isn't a very efficient way to do this, but whatever

func _ready():
    var connected_children = []
    for child in get_children():
        child.resized.connect(_resize)
        connected_children.append(child)

    # when children are added, reconnect
    child_entered_tree.connect(func():
        for child in connected_children:
            child.resized.disconnect(_resize)
        connected_children.clear()
        for child in get_children():
            child.resized.connect(_resize)
            connected_children.append(child)
        _resize()
    )
    
    _resize()

func _resize():
    custom_minimum_size = _get_minimum_size()

func _get_minimum_size() -> Vector2:
    var max_size = Vector2.ZERO
    for child in get_children():
        if child is Control:
            var child_size = child.get_combined_minimum_size()
            max_size.x = max(max_size.x, child_size.x)
            max_size.y = max(max_size.y, child_size.y)
    print(max_size)
    return max_size

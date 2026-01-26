@warning_ignore("missing_tool")
extends OutlinedPolygon

var chunk_position: Vector2i = Vector2i.ZERO

@export
var locked_background: Color = Color(0.0, 0.0, 0.0, 0.7)

@onready var bg: Polygon2D = $"Background"

var chunk_data: MapChunk
var surrounding_chunk_data: Array[MapChunk]

func _ready():
    chunk_position = $"..".chunk_position
    chunk_data = $"..".chunk_data
    surrounding_chunk_data = [
        MapSingleton.get_chunk_at(chunk_position + Vector2i.UP),
        MapSingleton.get_chunk_at(chunk_position + Vector2i.RIGHT),
        MapSingleton.get_chunk_at(chunk_position + Vector2i.DOWN),
        MapSingleton.get_chunk_at(chunk_position + Vector2i.LEFT)
    ]

    if chunk_data != null:
        chunk_data.unlocked_changed.connect(_on_chunk_unlocked_changed)
        _on_chunk_unlocked_changed(chunk_data.unlocked)
    else:
        push_error("Chunk data is null for chunk at position %s" % chunk_position)

    for neighbor in surrounding_chunk_data:
        if neighbor != null:
            neighbor.unlocked_changed.connect(func(_unlocked): _update_outline_visibility())

func _on_chunk_unlocked_changed(new_unlocked: bool) -> void:
    if new_unlocked:
        bg.color = Color.TRANSPARENT
    else:
        bg.color = locked_background
    _update_outline_visibility()

func _update_outline_visibility() -> void:
    outline_line_visibility = PackedByteArray()
    for dir in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
        var neighbor = MapSingleton.get_chunk_at(chunk_position + dir)
        if neighbor == null:
            outline_line_visibility.append(1)  
        elif chunk_data.unlocked:
            outline_line_visibility.append(int(not neighbor.unlocked))
        else:
            outline_line_visibility.append(int(neighbor.unlocked))

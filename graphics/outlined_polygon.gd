@tool

extends Polygon2D

class_name OutlinedPolygon

@export
var outline_color: Color = Color.BLACK

@export_range(0.0, 10.0, 0.01)
var outline_thickness: float = 2.0

@export
var outline_dashed: bool = false

@export
var dash_length: float = 10.0

var outline_line_visibility: PackedByteArray = []

func _draw():
    if outline_color.a == 0.0:
        return

    # This doesn't work with multiple polygons, but whatever
    var points = polygon
    var point_count = points.size()

    for i in point_count:
        if outline_line_visibility.size() == point_count and not outline_line_visibility[i]:
            continue

        var p1 = points[i]
        var p2 = points[(i + 1) % point_count]
        var direction = (p2 - p1).normalized()
        var normal = Vector2(-direction.y, direction.x)

        if outline_dashed:
            draw_dashed_line(
                p1, p2,
                outline_color,
                outline_thickness,
                dash_length,
                true, true
            )
        else:
            draw_line(
                p1 + normal * outline_thickness / 2,
                p2 + normal * outline_thickness / 2,
                outline_color,
                outline_thickness,
                true
            )

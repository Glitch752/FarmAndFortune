extends Node2D

var chunk_position: Vector2i = Vector2i.ZERO
@onready var chunk_data: MapChunk = MapSingleton.get_chunk_at(chunk_position)

var debug_segments: Array[Array] = []

func _ready():
    $"GroundTileMap".self_modulate = Color.TRANSPARENT

    generate_ground_polygon()

    queue_redraw()

## Uses marching squares to generate a ground polygon based on the terrain types of the map
func generate_ground_polygon():
    var tile_size = $"GroundTileMap".tile_set.tile_size.x

    var is_filled = func(pos: Vector2i):
        return MapSingleton.get_terrain_at(pos) == MapSingleton.TerrainType.GRASS

    # Marching squares lookup table for edges
    var edge_table = [
        [], # 0
        [[0.0, 0.5], [0.5, 0.0]], # 1
        [[0.5, 0.0], [1.0, 0.5]], # 2
        [[0.0, 0.5], [1.0, 0.5]], # 3
        [[1.0, 0.5], [0.5, 1.0]], # 4
        [[0.0, 0.5], [0.5, 0.0], [1.0, 0.5], [0.5, 1.0]], # 5 (ambiguous)
        [[0.5, 0.0], [0.5, 1.0]], # 6
        [[0.0, 0.5], [0.5, 1.0]], # 7
        [[0.5, 1.0], [0.0, 0.5]], # 8
        [[0.5, 0.0], [0.5, 1.0]], # 9
        [[1.0, 0.5], [0.5, 1.0], [0.0, 0.5], [0.5, 0.0]], # 10 (ambiguous)
        [[1.0, 0.5], [0.5, 1.0]], # 11
        [[1.0, 0.5], [0.0, 0.5]], # 12
        [[1.0, 0.5], [0.5, 0.0]], # 13
        [[0.5, 0.0], [0.0, 0.5]], # 14
        [] # 15
    ]

    # First, generate the edge segments
    var segments: Array[Array] = []
    for y in MapSingleton.CHUNK_SIZE:
        for x in MapSingleton.CHUNK_SIZE:
            var square_index = 0
            if is_filled.call(Vector2i(x, y)):
                square_index |= 1
            if is_filled.call(Vector2i(x + 1, y)):
                square_index |= 2
            if is_filled.call(Vector2i(x + 1, y + 1)):
                square_index |= 4
            if is_filled.call(Vector2i(x, y + 1)):
                square_index |= 8

            var edges = edge_table[square_index]
            for i in range(0, edges.size(), 2):
                var p1 = Vector2((x + edges[i][0]) * tile_size, (y + edges[i][1]) * tile_size)
                var p2 = Vector2((x + edges[i + 1][0]) * tile_size, (y + edges[i + 1][1]) * tile_size)
                segments.append([p1, p2])

    # Add segments around all borders with no terrain
    var clampside = func(v: float) -> float:
        return clamp(v, 0, MapSingleton.CHUNK_SIZE * 1.0)
    for x in MapSingleton.CHUNK_SIZE + 1:
        var y = 0
        if not is_filled.call(Vector2i(x, y)):
            var p1 = Vector2(clampside.call(x - 0.5) * tile_size, y * tile_size)
            var p2 = Vector2(clampside.call(x + 0.5) * tile_size, y * tile_size)
            segments.append([p1, p2])
        
        y = MapSingleton.CHUNK_SIZE - 1
        if not is_filled.call(Vector2i(x, y + 1)):
            var p1 = Vector2(clampside.call(x + 0.5) * tile_size, (y + 1) * tile_size)
            var p2 = Vector2(clampside.call(x - 0.5) * tile_size, (y + 1) * tile_size)
            segments.append([p1, p2])
    for y in MapSingleton.CHUNK_SIZE + 1:
        var x = 0
        if not is_filled.call(Vector2i(x, y)):
            var p1 = Vector2(x * tile_size, clampside.call(y + 0.5) * tile_size)
            var p2 = Vector2(x * tile_size, clampside.call(y - 0.5) * tile_size)
            segments.append([p1, p2])
        
        x = MapSingleton.CHUNK_SIZE - 1
        if not is_filled.call(Vector2i(x + 1, y)):
            var p1 = Vector2((x + 1) * tile_size, clampside.call(y - 0.5) * tile_size)
            var p2 = Vector2((x + 1) * tile_size, clampside.call(y + 0.5) * tile_size)
            segments.append([p1, p2])
    
    debug_segments = segments.duplicate()

    # Now, link segments into distinct polygons
    var polygons: Array[Array] = []

    while segments.size() > 0:
        var current_segment = segments.pop_front()
        var polygon: Array = [current_segment[0], current_segment[1]]

        var extended = true
        while extended:
            extended = false
            for i in range(segments.size()):
                var seg = segments[i]
                if seg[0] == polygon[-1]:
                    polygon.append(seg[1])
                    segments.remove_at(i)
                    extended = true
                    break
                elif seg[1] == polygon[-1]:
                    polygon.append(seg[0])
                    segments.remove_at(i)
                    extended = true
                    break
                elif seg[0] == polygon[0]:
                    polygon.insert(0, seg[1])
                    segments.remove_at(i)
                    extended = true
                    break
                elif seg[1] == polygon[0]:
                    polygon.insert(0, seg[0])
                    segments.remove_at(i)
                    extended = true
                    break

        polygons.append(polygon)
    
    # Make a polygon using this data
    var points: PackedVector2Array = []
    var indices: Array[PackedInt32Array] = []
    for polygon in polygons:
        var start_index = points.size()
        for point in polygon:
            points.append(point)
        var index_array = PackedInt32Array()
        for i in range(polygon.size()):
            index_array.append(start_index + i)
        indices.append(index_array)
    
    var poly = Polygon2D.new()
    poly.polygon = points
    poly.polygons = indices

    poly.show_behind_parent = true
    # poly.invert_enabled = true
    # poly.invert_border = 1
    add_child(poly)

func _draw() -> void:
    for segment in debug_segments:
        draw_line(segment[0], segment[1], Color.RED, 2)

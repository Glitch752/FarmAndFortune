extends Polygon2D

const JAGGED_STRENGTH: float = 0.1 # how much the edges stick out
const JAGGED_DETAIL: int = 3 # how many extra points per edge

@export var terrain_types: Array[MapSingleton.TerrainType]
@export var layers: Array[GroundLayer]

var chunk_data: MapChunk
var chunk_position: Vector2i

var ground_mesh: ArrayMesh = null

func _ready():
    # Add a child MeshInstance2D for each layer
    var i = 0
    for layer in layers:
        var mesh_instance = MeshInstance2D.new()
        mesh_instance.modulate = layer.color
        mesh_instance.position = Vector2(0, layer.y_offset)
        
        i -= 1
        mesh_instance.z_index = i
        
        add_child(mesh_instance)

    if ground_mesh != null:
        for child in get_children():
            child.mesh = ground_mesh

func init(data: MapChunk, pos: Vector2i):
    chunk_data = data
    chunk_position = pos

    generate_ground_polygon()

## uses marching squares to generate a ground polygon based on the terrain types of the map
func generate_ground_polygon():
    chunk_data._cell_geometry_cache.clear()

    var is_filled = func(pos: Vector2i):
        return MapSingleton.get_terrain_at(
            pos + chunk_position * MapSingleton.CHUNK_SIZE
        ) == MapSingleton.TerrainType.GRASS

    # 1: TL, 2: TR, 4: BR, 8: BL
    var polygon_table = {
        0: [],
        1:  [PackedVector2Array([Vector2(0, 0.5), Vector2(0, 0), Vector2(0.5, 0)])],
        2:  [PackedVector2Array([Vector2(0.5, 0), Vector2(1, 0), Vector2(1, 0.5)])],
        3:  [PackedVector2Array([Vector2(0, 0.5), Vector2(0, 0), Vector2(1, 0), Vector2(1, 0.5)])],
        4:  [PackedVector2Array([Vector2(1, 0.5), Vector2(1, 1), Vector2(0.5, 1)])],
        5:  [ # Ambiguous (Saddle): TL and BR filled
                PackedVector2Array([Vector2(0, 0.5), Vector2(0, 0), Vector2(0.5, 0)]),
                PackedVector2Array([Vector2(1, 0.5), Vector2(1, 1), Vector2(0.5, 1)])
            ],
        6:  [PackedVector2Array([Vector2(0.5, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0.5, 1)])],
        7:  [PackedVector2Array([Vector2(0, 0.5), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0.5, 1)])],
        8:  [PackedVector2Array([Vector2(0.5, 1), Vector2(0, 1), Vector2(0, 0.5)])],
        9:  [PackedVector2Array([Vector2(0.5, 1), Vector2(0, 1), Vector2(0, 0), Vector2(0.5, 0)])],
        10: [ # Ambiguous (Saddle): TR and BL filled
                PackedVector2Array([Vector2(0.5, 0), Vector2(1, 0), Vector2(1, 0.5)]),
                PackedVector2Array([Vector2(0.5, 1), Vector2(0, 1), Vector2(0, 0.5)])
            ],
        11: [PackedVector2Array([Vector2(0.5, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 0.5)])],
        12: [PackedVector2Array([Vector2(1, 0.5), Vector2(1, 1), Vector2(0, 1), Vector2(0, 0.5)])],
        13: [PackedVector2Array([Vector2(1, 0.5), Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(0.5, 0)])],
        14: [PackedVector2Array([Vector2(0.5, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(0, 0.5)])],
        15: [PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])]
    }
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    for y in MapSingleton.CHUNK_SIZE:
        for x in MapSingleton.CHUNK_SIZE:
            var square_index = 0
            if is_filled.call(Vector2i(x, y)):         square_index |= 1
            if is_filled.call(Vector2i(x + 1, y)):     square_index |= 2
            if is_filled.call(Vector2i(x + 1, y + 1)): square_index |= 4
            if is_filled.call(Vector2i(x, y + 1)):     square_index |= 8
            
            if square_index == 0: continue
            
            var grid_pos = Vector2i(x, y)
            var final_polys: Array[PackedVector2Array] = []
            var base_offset = Vector2(x, y) * MapSingleton.TILE_SIZE
            
            for template_poly in polygon_table[square_index]:
                var built_poly = _construct_jagged_poly(template_poly, base_offset)
                final_polys.append(built_poly)
                
                _triangulate_poly_fan(st, built_poly)

            chunk_data._cell_geometry_cache[grid_pos] = final_polys

    # 3. finalize
    st.index() # Optimize vertices (this is super inefficient anyway though oops)
    ground_mesh = st.commit()

    if is_node_ready():
        for child in get_children():
            child.mesh = ground_mesh


func _triangulate_poly_fan(st: SurfaceTool, poly: PackedVector2Array):
    # calculate a center point (centroid?) to create a triangle fan from
    var center = Vector2.ZERO
    for p in poly:
        center += p
    center /= poly.size()

    var add_vertex = func(v: Vector2):
        st.add_vertex(Vector3(v.x, v.y, 0))
    
    for i in range(poly.size()):
        add_vertex.call(poly[i])
        add_vertex.call(poly[(i + 1) % poly.size()])
        add_vertex.call(center)

## adds jagged edges to the "perfect" outlines created by marching squares
## to make the terrain look less blocky
func _construct_jagged_poly(template: PackedVector2Array, poly_offset: Vector2) -> PackedVector2Array:
    var result = PackedVector2Array()
    var count = template.size()
    
    for i in range(count):
        var p1_local = template[i]
        var p2_local = template[(i + 1) % count]
        
        var p1_world = (p1_local * MapSingleton.TILE_SIZE) + poly_offset
        var p2_world = (p2_local * MapSingleton.TILE_SIZE) + poly_offset
        
        # Add the start point
        result.append(p1_world)
        
        # Check if this edge is an "Iso-Edge" (internal rock face)
        if _is_midpoint(p1_local) and _is_midpoint(p2_local):
            var jagged = _generate_jagged_edge_points(p1_world, p2_world)
            result.append_array(jagged)
            
    return result

func _is_midpoint(v: Vector2) -> bool:
    return is_equal_approx(v.x, 0.5) or is_equal_approx(v.y, 0.5)


func _generate_jagged_edge_points(start: Vector2, end: Vector2) -> PackedVector2Array:
    var points = PackedVector2Array()
    var normal = (end - start).orthogonal().normalized()

    # deterministic seed based on position so the mesh doesn't change
    var seed_base = start.x * 33.0 + start.y * 71.0
    
    for i in range(1, JAGGED_DETAIL + 1):
        var t = i / float(JAGGED_DETAIL + 1)
        var base_pos = start.lerp(end, t)

        var noise = sin(seed_base + i * 12.0)  # simple pseudo-random
        points.append(base_pos + (normal * noise * (MapSingleton.TILE_SIZE * JAGGED_STRENGTH)))
        
    return points

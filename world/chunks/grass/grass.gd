extends MultiMeshInstance2D

@onready var tiles: TileMapLayer = $".."

func _ready() -> void:
    # Calculate the extent from the tilemap size
    # var extent = max(tiles.get_used_rect().size.x, tiles.get_used_rect().size.y) * tiles.tile_set.tile_size.x / 2
    var extent = MapSingleton.CHUNK_SIZE * tiles.tile_set.tile_size.x / 2

    var mesh := ArrayMesh.new()
    var arrays = []

    var verts = PackedVector2Array([
        Vector2(-1, 0),
        Vector2(1, 0),
        Vector2(0, -4.5),
    ])

    var uvs = PackedVector2Array([
        Vector2(0, 1),
        Vector2(1, 1),
        Vector2(0.5, 0),
    ])

    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = verts
    arrays[Mesh.ARRAY_TEX_UV] = uvs

    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_2D
    multimesh.use_colors = false
    multimesh.mesh = mesh

    var scatter_count = 25000

    # Prevents Godot from trying to calculate it
    multimesh.custom_aabb = AABB(Vector3(-extent, -extent, 0), Vector3(extent * 2, extent * 2, 0))

    var check_tile = func(x, y):
        var tile_pos = tiles.local_to_map(tiles.to_local(Vector2(x, y)))
        var cell_data = tiles.get_cell_tile_data(tile_pos)
        if cell_data == null:
            return true
        if cell_data.get_custom_data("has_grass") != true:
            return false
        return true

    var base_scale = 0.6
    var side_margin = base_scale * 1.5


    var instances = 0
    var instance_positions = []
    for i in scatter_count:
        var x = randf() * extent * 2 - extent
        var y = float(i) / scatter_count * extent * 2 - extent

        if not check_tile.call(x - side_margin, y) or not check_tile.call(x + side_margin, y):
            continue
            
        var instance_scale = randf() * base_scale + base_scale
        var instance_transform = Transform2D()\
            .scaled(Vector2.ONE * instance_scale)\
            .translated(Vector2(x, y))

        instance_positions.append(instance_transform)
        instances += 1
    
    multimesh.instance_count = instances
    for i in instances:
        multimesh.set_instance_transform_2d(i, instance_positions[i])

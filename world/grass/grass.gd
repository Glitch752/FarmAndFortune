extends MultiMeshInstance2D

func _ready() -> void:
    var mesh := ArrayMesh.new()
    var arrays = []

    var verts = PackedVector2Array([
        Vector2(-2, 0),
        Vector2(2, 0),
        Vector2(0, -9),
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

    # TODO: Distribute better
    multimesh.instance_count = 20000
    # Prevents Godot from trying to calculate it
    multimesh.custom_aabb = AABB(Vector3(-500, -500, 0), Vector3(1000, 1000, 0))
    
    for i in multimesh.instance_count:
        var x = randi() % 200 - 100
        var y = float(i) / multimesh.instance_count * 200 - 100
        var instance_scale = randf() * 0.5 + 0.75
        var instance_transform = Transform2D()\
            .scaled(Vector2.ONE * instance_scale)\
            .translated(Vector2(x, y))
        multimesh.set_instance_transform_2d(i, instance_transform)

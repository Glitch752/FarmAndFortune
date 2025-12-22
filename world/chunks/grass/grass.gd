extends MultiMeshInstance2D

@onready var chunk: Node2D = $".."

func _ready() -> void:
    generate_mesh_positions()

func generate_mesh_positions():
    # Calculate the extent from the tilemap size
    # var extent = max(tiles.get_used_rect().size.x, tiles.get_used_rect().size.y) * tiles.tile_set.tile_size.x / 2

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

    # Prevents Godot from trying to calculate it
    var extent = MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE / float(2)
    multimesh.custom_aabb = AABB(Vector3(-extent, -extent, 0), Vector3(extent * 2, extent * 2, 0))

    var chunk_data = $"../..".chunk_data
    var grass_transforms: Array[Transform2D] = chunk_data.grass_transforms

    multimesh.instance_count = grass_transforms.size()
    for i in grass_transforms.size():
        multimesh.set_instance_transform_2d(i, grass_transforms[i])

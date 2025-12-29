extends MultiMeshInstance2D

const async_lock = preload("res://scripts/utils.gd").async_lock

@onready var chunk: Node2D = $"../.."

func _ready() -> void:
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
    multimesh.custom_aabb = AABB(Vector3(0, 0, 0), Vector3(extent * 2, extent * 2, 0))

    generate_mesh_positions()

    material = material.duplicate()
    (material as ShaderMaterial).set_shader_parameter("origin_pos",
        Vector2(chunk.chunk_position) * MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE
            + Vector2.ONE * MapSingleton.TILE_SIZE / 2.
    )
    (material as ShaderMaterial).set_shader_parameter("clip_x", MapSingleton.CHUNK_SIZE * MapSingleton.TILE_SIZE);

    chunk.chunk_data.regenerate_grass.connect(generate_mesh_positions)

func generate_mesh_positions():
    var chunk_data = chunk.chunk_data

    if not await async_lock.call(chunk_data.transforms_mutex):
        print("could not lock transforms mutex for chunk %s when generating grass transforms. Avoided blocking." %
            chunk.chunk_position)
        return

    var grass_transforms: Array[Transform2D] = chunk_data.grass_transforms
    multimesh.instance_count = grass_transforms.size()
    for i in grass_transforms.size():
        multimesh.set_instance_transform_2d(i, grass_transforms[i])
        
    chunk_data.transforms_mutex.unlock()

# Blegh objects need to be in their own files for serialization to work properly
class_name SaveFileData extends Resource

@export var metadata: SaveFileMetaData
@export var inventory: Dictionary[StringName, int] = {
    &"carrot_seeds": 10
}
@export var world_data_version: Serialization.WorldDataVersion = Serialization.WorldDataVersion.VERSION_1
@export var serialized_world: PackedByteArray = PackedByteArray()

# Blegh objects need to be in their own files for serialization to work properly
class_name SaveFileMetaData extends Resource

@export var name: String = ""
@export var play_time_seconds: float = 0
@export var character: StringName = &"farmer_1"
@export var last_modified: float = 0

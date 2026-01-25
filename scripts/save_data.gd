extends Node

# String | null
var loaded_save_id: Variant = null

var inventory: Dictionary[StringName, int] = {
    &"carrot_seeds": 10
}

var character: StringName = &"farmer_1"
var play_time_seconds: float = 0

func _init() -> void:
    pass

class SaveFileMetaData:
    var name: String = ""
    var play_time_seconds: float = 0
    var character: StringName = &"farmer_1"
    var last_modified: float = 0

class SaveFileData:
    var metadata: SaveFileMetaData
    var inventory: Dictionary[StringName, int] = {}
    var world_data_version: Serialization.WorldDataVersion = Serialization.WorldDataVersion.VERSION_1
    var serialized_world: PackedByteArray = PackedByteArray()

func save() -> void:
    if loaded_save_id == null:
        push_error("No save loaded")
        return

    var data = SaveFileData.new()
    data.inventory = inventory
    data.world_data_version = Serialization.WorldDataVersion.VERSION_1

    data.metadata = SaveFileMetaData.new()
    data.metadata.play_time_seconds = play_time_seconds
    data.metadata.character = character
    data.metadata.last_modified = Time.get_unix_time_from_system()

    var buffer = StreamPeerBuffer.new()
    buffer.data_array = PackedByteArray()
    buffer.big_endian = true
    MapSingleton.serialize_world(buffer)

    data.serialized_world = buffer.data_array

    _save(loaded_save_id, data)

func load(save_id: String) -> void:
    var data = _load(save_id)
    if data == null:
        push_error("Failed to load save: %s" % save_id)
        return
    loaded_save_id = save_id
    inventory = data.inventory
    play_time_seconds = data.play_time_seconds
    character = data.character

    var buffer = StreamPeerBuffer.new()
    buffer.data_array = data.serialized_world
    buffer.big_endian = true
    MapSingleton.deserialize_world(buffer, data.world_data_version)

func create_new_save(save_id: String) -> void:
    var data = SaveFileData.new()
    _save(save_id, data)
    loaded_save_id = save_id
    inventory = {}

func _save(save_id: String, data: SaveFileData) -> void:
    var file = FileAccess.open("user://saves/%s.save" % save_id
        , FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing: %s" % save_id)
        return
    
    file.store_var(data.metadata)
    data.metadata = null # Clear metadata to avoid storing it twice
    file.store_var(data)
    file.close()

func _load(save_id: String) -> SaveFileData:
    var file = FileAccess.open("user://saves/%s.save" % save_id
        , FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading: %s" % save_id)
        return null
    
    var metadata = file.get_var() as SaveFileMetaData
    var data = file.get_var()
    data.metadata = metadata

    file.close()
    return data

func delete_save(save_id: String) -> void:
    var save_path = "user://saves/%s.save" % save_id
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)
    else:
        push_warning("Save file does not exist: %s" % save_id)

func list_saves() -> Dictionary[String, SaveFileMetaData]:
    var dir = DirAccess.open("user://saves")
    var saves: Dictionary[String, SaveFileMetaData] = {}
    if dir == null:
        return saves
    dir.list_dir_begin()
    
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".save"):
            var save_id = file_name.substr(0, file_name.length() - 5)
            var file = FileAccess.open("user://saves/%s" % file_name
                , FileAccess.READ)
            if file != null:
                var metadata = file.get_var() as SaveFileMetaData
                saves.set(save_id, metadata)
                file.close()
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return saves
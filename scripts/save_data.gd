extends Node

# String | null
var loaded_save_name: Variant = null

var inventory: Dictionary[StringName, int] = {
    &"carrot_seeds": 10
}

func _init() -> void:
    pass

class SaveFileData:
    var inventory: Dictionary[StringName, int] = {}
    var world_data_version: Serialization.WorldDataVersion = Serialization.WorldDataVersion.VERSION_1
    var serialized_world: PackedByteArray = PackedByteArray()

func save() -> void:
    if loaded_save_name == null:
        push_error("No save loaded")
        return

    var data = SaveFileData.new()
    data.inventory = inventory
    data.world_data_version = Serialization.WorldDataVersion.VERSION_1
    
    var buffer = StreamPeerBuffer.new()
    buffer.data_array = PackedByteArray()
    buffer.big_endian = true
    MapSingleton.serialize_world(buffer)

    data.serialized_world = buffer.data_array

    _save(loaded_save_name, data)

func load(save_name: String) -> void:
    var data = _load(save_name)
    if data == null:
        push_error("Failed to load save: %s" % save_name)
        return
    loaded_save_name = save_name
    inventory = data.inventory

    var buffer = StreamPeerBuffer.new()
    buffer.data_array = data.serialized_world
    buffer.big_endian = true
    MapSingleton.deserialize_world(buffer, data.world_data_version)

func create_new_save(save_name: String) -> void:
    var data = SaveFileData.new()
    _save(save_name, data)
    loaded_save_name = save_name
    inventory = {}

func _save(save_name: String, data: SaveFileData) -> void:
    var file = FileAccess.open("user://saves/%s.save" % save_name
        , FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing: %s" % save_name)
        return
    file.store_var(data)
    file.close()

func _load(save_name: String) -> SaveFileData:
    var file = FileAccess.open("user://saves/%s.save" % save_name
        , FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading: %s" % save_name)
        return null
    var data = file.get_var()
    file.close()
    return data

func delete_save(save_name: String) -> void:
    var save_path = "user://saves/%s.save" % save_name
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)
    else:
        push_warning("Save file does not exist: %s" % save_name)

class SaveFile:
    var name: String
    var last_modified: int

    func last_modified_datetime() -> String:
        return Time.get_datetime_string_from_unix_time(last_modified)

func list_saves() -> Array[SaveFile]:
    var dir = DirAccess.open("user://saves")
    var saves: Array[SaveFile] = []
    if dir == null:
        return saves
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".save"):
            var save_file = SaveFile.new()
            save_file.name = file_name.replace(".save", "")
            save_file.last_modified = dir.get_modified_time(file_name)
            saves.append(save_file)
        file_name = dir.get_next()
    dir.list_dir_end()
    return saves
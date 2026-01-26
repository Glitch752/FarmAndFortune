extends Node

# String | null
var loaded_save_id: Variant = null
var loaded_save_name: String = ""

var inventory: Dictionary[StringName, int] = {}

var character_name: String = ""
var character: StringName = &"farmer_1"
var play_time_seconds: float = 0

func format_play_time() -> String:
    var seconds = int(play_time_seconds) % 60
    @warning_ignore("integer_division")
    var total_minutes = int(play_time_seconds) / 60
    var minutes = total_minutes % 60
    @warning_ignore("integer_division")
    var hours = total_minutes / 60
    return "%02d:%02d:%02d" % [hours, minutes, seconds]

var money: int = 0
var gross_earnings: int = 0
var total_crops_harvested: int = 0

var camera_position: Vector2

var dialogue_state: DialogueState = DialogueState.new()

func _init() -> void:
    pass

func save() -> void:
    if loaded_save_id == null:
        push_error("No save loaded")
        return

    var data = SaveFileData.new()
    
    data.inventory = inventory
    data.camera_position = camera_position
    data.dialogue_state = dialogue_state

    data.world_data_version = Serialization.WorldDataVersion.VERSION_1

    data.metadata = SaveFileMetaData.new()
    data.metadata.name = loaded_save_name

    data.metadata.play_time_seconds = play_time_seconds
    data.metadata.character = character
    data.metadata.last_modified = Time.get_unix_time_from_system()

    data.metadata.money = money
    data.metadata.gross_earnings = gross_earnings
    data.metadata.total_crops_harvested = total_crops_harvested

    var buffer = StreamPeerBuffer.new()
    buffer.data_array = PackedByteArray()
    buffer.big_endian = true
    MapSingleton.serialize_world(buffer)

    data.serialized_world = buffer.data_array

    _save(loaded_save_id, data)

func load_save(save_id: String) -> void:
    var data = _load(save_id)
    if data == null:
        push_error("Failed to load save: %s" % save_id)
        return
    
    loaded_save_id = save_id
    loaded_save_name = data.metadata.name

    dialogue_state = data.dialogue_state

    inventory = data.inventory
    camera_position = data.camera_position

    character_name = data.metadata.character_name
    character = data.metadata.character
    play_time_seconds = data.metadata.play_time_seconds

    money = data.metadata.money
    gross_earnings = data.metadata.gross_earnings
    total_crops_harvested = data.metadata.total_crops_harvested

    if character_name == "":
        character_name = "Unnamed"
    if loaded_save_name == "":
        loaded_save_name = "Unnamed Save"

    if data.serialized_world.size() > 0:
        # World has already been saved; otherwise, we'll generate it
        var buffer = StreamPeerBuffer.new()
        buffer.data_array = data.serialized_world
        buffer.big_endian = true
        MapSingleton.deserialize_world(buffer, data.world_data_version)

    # Load the level scene
    get_tree().change_scene_to_packed(preload("res://scenes/Level.tscn"))

func create_new_save(save_name: String, save_character_name: String, character_id: String) -> void:
    var metadata = SaveFileMetaData.new()
    metadata.name = save_name
    metadata.character_name = save_character_name
    metadata.character = character_id
    metadata.last_modified = Time.get_unix_time_from_system()

    var data = SaveFileData.new()
    data.metadata = metadata

    var save_id = "%s_%d" % [save_name.to_lower().replace(" ", "_"), Time.get_unix_time_from_system()]
    
    _save(save_id, data)
    
    load_save(save_id)

func _save(save_id: String, data: SaveFileData) -> void:
    # Make sure the saves directory exists
    var dir = DirAccess.open("user://saves")
    if dir == null:
        DirAccess.make_dir_recursive_absolute("user://saves")
    
    var file = FileAccess.open("user://saves/%s.save" % save_id, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing: %s" % save_id)
        return
    
    file.store_var(data.metadata, true)
    data.metadata = null # Clear metadata to avoid storing it twice
    file.store_var(data, true)
    file.close()

    print("Saved game: %s" % save_id)

func _load(save_id: String) -> SaveFileData:
    var file = FileAccess.open("user://saves/%s.save" % save_id
        , FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading: %s" % save_id)
        return null
    
    var metadata = file.get_var(true) as SaveFileMetaData
    var data = file.get_var(true)
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
                var metadata = file.get_var(true) as SaveFileMetaData
                if metadata == null:
                    push_error("Failed to read metadata for save: %s" % save_id)
                    # Delete the corrupted save file
                    file.close()
                    delete_save(save_id)
                else:
                    saves.set(save_id, metadata)
                    file.close()
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return saves

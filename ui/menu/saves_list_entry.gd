@tool

extends SizedButton

@export var save_name: String = "Save 1":
    set(value):
        save_name = value
        _update()
@export var play_time_seconds: float = 0.0:
    set(value):
        play_time_seconds = value
        _update()
@export var last_modified: float = 0.0:
    set(value):
        last_modified = value
        _update()

func set_metadata(metadata: SaveData.SaveFileMetaData) -> void:
    save_name = metadata.name
    play_time_seconds = metadata.play_time_seconds
    last_modified = metadata.last_modified
    _update()

func _update() -> void:
    if not is_inside_tree():
        return

    $%Name.text = save_name
    
    @warning_ignore("integer_division")
    var hours = int(play_time_seconds) / 3600
    @warning_ignore("integer_division")
    var minutes = (int(play_time_seconds) % 3600) / 60
    var seconds = int(play_time_seconds) % 60
    $%Playtime.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

    var time = Time.get_datetime_string_from_unix_time(int(last_modified))
    $%LastModified.text = time

func _ready() -> void:
    _update()

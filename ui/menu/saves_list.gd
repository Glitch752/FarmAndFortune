extends VBoxContainer

@onready var no_saves_label = $NoSaves

const SavesListEntry = preload("res://ui/menu/SavesListEntry.tscn")

func _ready() -> void:
    # Make no_saves_label an internal child
    remove_child(no_saves_label)
    add_child(no_saves_label, false, InternalMode.INTERNAL_MODE_FRONT)

    _refresh_saves_list()

func _refresh_saves_list() -> void:
    var saves = SaveData.list_saves()
    if saves.size() == 0:
        no_saves_label.show()
    else:
        no_saves_label.hide()
    
    for child in get_children():
        child.queue_free()
    
    for save_id in saves.keys():
        var save_metadata = saves[save_id]
        var save_entry = SavesListEntry.instantiate()
        save_entry.set_metadata(save_metadata)
        add_child(save_entry)

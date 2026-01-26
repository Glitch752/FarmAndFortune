extends VBoxContainer

const DialogueEntryDisplay = preload("res://ui/dialogue/DialogueEntryDisplay.tscn")

func _ready() -> void:
    # For development: clear any existing dialogue entries
    for child in get_children():
        child.queue_free()

    DialogueSingleton.show_dialogue_entry.connect(_on_show_dialogue_entry)
    DialogueSingleton.dialogue_sequence_ended.connect(_on_dialogue_sequence_ended)

func _on_show_dialogue_entry(entry: DialogueEntry) -> void:
    var dialogue_entry_display = DialogueEntryDisplay.instantiate()
    dialogue_entry_display.entry = entry
    add_child(dialogue_entry_display)

    if get_child_count() > 2:
        for i in range(get_child_count() - 2):
            get_child(i).remove()

func _on_dialogue_sequence_ended() -> void:
    for child in get_children():
        child.remove()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") and get_child_count() > 0:
        DialogueSingleton.show_next()

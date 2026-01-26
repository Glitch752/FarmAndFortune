extends Node

signal show_dialogue_entry(entry: DialogueEntry)
signal dialogue_sequence_ended()

var dialogue_state: DialogueState:
    get:
        return SaveData.dialogue_state
    set(value):
        SaveData.dialogue_state = value

func has_seen_sequence(sequence_id: String) -> bool:
    return dialogue_state.seen_dialogue_sequences.has(sequence_id)

var current_dialogue_sequence: String = ""
var dialogue_queue: Array[DialogueEntry] = []

## Starts a dialogue sequence if it hasn't been seen before.
func start_dialogue_sequence(sequence_id: String, dialogue_entries: Array[DialogueEntry]) -> void:
    if has_seen_sequence(sequence_id):
        return
    
    dialogue_queue = dialogue_entries.duplicate()
    _show_next_dialogue_entry()

func show_next() -> void:
    _show_next_dialogue_entry()

func _show_next_dialogue_entry() -> void:
    if dialogue_queue.size() == 0:
        _end_dialogue_sequence()
        return
    
    var entry: DialogueEntry = dialogue_queue.pop_front()
    show_dialogue_entry.emit(entry)

func _end_dialogue_sequence() -> void:
    if current_dialogue_sequence != "":
        dialogue_state.seen_dialogue_sequences.set(current_dialogue_sequence, 1)
        current_dialogue_sequence = ""
    
    dialogue_sequence_ended.emit()

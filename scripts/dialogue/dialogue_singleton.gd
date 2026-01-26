extends Node

signal show_dialogue_entry(entry: DialogueEntry)
signal dialogue_sequence_ended()
signal dialogue_event_triggered(event_name: String)

var dialogue_state: DialogueState:
    get:
        return SaveData.dialogue_state
    set(value):
        SaveData.dialogue_state = value

func has_seen_sequence(sequence_id: String) -> bool:
    return dialogue_state.seen_dialogue_sequences.has(sequence_id)

var current_dialogue_sequence: String = ""
var dialogue_queue: Array[DialogueStep] = []

## Starts a dialogue sequence if it hasn't been seen before.
func start_dialogue_sequence(sequence_id: String, dialogue_steps: Array[DialogueStep]) -> void:
    if current_dialogue_sequence == sequence_id:
        return

    if current_dialogue_sequence != "":
        push_error("Dialogue sequence already in progress: %s" % current_dialogue_sequence)
        return

    if has_seen_sequence(sequence_id):
        return
    
    current_dialogue_sequence = sequence_id
    dialogue_queue = dialogue_steps.duplicate()
    _show_next_dialogue_step()

func show_next() -> void:
    _show_next_dialogue_step()

func _show_next_dialogue_step() -> void:
    if dialogue_queue.size() == 0:
        _end_dialogue_sequence()
        return
    
    var step: DialogueStep = dialogue_queue.pop_front()

    if step is DialogueStepEvent:
        dialogue_event_triggered.emit(step.event_name)
        _show_next_dialogue_step()
        return

    show_dialogue_entry.emit(step as DialogueEntry)

func _end_dialogue_sequence() -> void:
    if current_dialogue_sequence != "":
        dialogue_state.seen_dialogue_sequences.append(current_dialogue_sequence)
        current_dialogue_sequence = ""
    
    dialogue_sequence_ended.emit()

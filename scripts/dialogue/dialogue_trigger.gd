class_name DialogueTrigger extends Node

@export var dialogue_sequence: String = ""
@export var dialogue: Array[DialogueStep] = []

func trigger() -> void:
    DialogueSingleton.start_dialogue_sequence(dialogue_sequence, dialogue)
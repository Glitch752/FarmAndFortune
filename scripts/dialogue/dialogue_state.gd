# Needs to be in its own file for proper serialization blegh

## State related to dialogue management that must be persisted in saves
class_name DialogueState extends Resource

var seen_dialogue_sequences: Dictionary[String, int] = {}

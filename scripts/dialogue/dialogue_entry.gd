class_name DialogueEntry extends Resource

enum DialogueSpeaker {
    FARMER,
    DEBT_COLLECTOR
}

@export var speaker: DialogueSpeaker = DialogueSpeaker.FARMER
@export var text: String = ""

class_name DialogueTriggerMoney extends DialogueTrigger

@export var required_money: int = 0

func _ready() -> void:
    if DialogueSingleton.has_seen_sequence(dialogue_sequence):
        queue_free()

func _process(_delta: float) -> void:
    if SaveData.money >= required_money:
        trigger()
        queue_free()
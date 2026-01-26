@tool

extends TransformContainer

var speaker_data: Dictionary[DialogueEntry.DialogueSpeaker, Dictionary] = {
    DialogueEntry.DialogueSpeaker.FARMER: {
        "name": "Farmer",
        "image": null,
        "side": "left"
    },
    DialogueEntry.DialogueSpeaker.DEBT_COLLECTOR: {
        "name": "Debt Collector",
        "image": preload("res://art/characters/debt_collector.png"),
        "side": "right"
    }
}

@export var entry: DialogueEntry:
    set(value):
        entry = value
        _update_display()
    get:
        return entry

@onready var speaker_name: Label = $%SpeakerName
@onready var dialogue_text: RichTextLabel = $%DialogueText
@onready var speaker_image: TextureRect = $%SpeakerImage
@onready var horizontal_layout: HBoxContainer = $%HorizontalLayout

func _init() -> void:
    if Engine.is_editor_hint():
        return
    
    visible = false
    modulate.a = 0.0
    visual_position = Vector2(0, 10)
    effective_scale = Vector2(1, 0)

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    
    dialogue_text.visible_ratio = 0.0

    _update_display()

    await get_tree().process_frame

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)

    visible = true
    tween.tween_property(self, "modulate:a", 1.0, 0.5)
    tween.parallel().tween_property(self, "visual_position:y", 0.0, 0.5)
    tween.parallel().tween_property(self, "effective_scale:y", 1.0, 0.5)

    var time = dialogue_text.get_total_character_count() * 0.015
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(dialogue_text, "visible_ratio", 1.0, time)

func remove() -> void:
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN_OUT)

    tween.tween_property(self, "modulate:a", 0.0, 0.5)
    tween.parallel().tween_property(self, "visual_position:y", -10.0, 0.5)
    
    await tween.finished
    queue_free()

func _update_display() -> void:
    if entry == null or not is_node_ready():
        return
    
    var speaker_info: Dictionary = speaker_data.get(entry.speaker, {})
    var side: String = speaker_info.get("side", "left")

    horizontal_layout.layout_direction = Control.LAYOUT_DIRECTION_LTR if side == "left" else Control.LAYOUT_DIRECTION_RTL
    dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if side == "left" else HORIZONTAL_ALIGNMENT_RIGHT
    
    speaker_name.text = speaker_info.get("name", "Unknown")
    dialogue_text.text = entry.text
    
    var speaker_texture: Texture = speaker_info.get("image")
    if speaker_texture != null:
        speaker_image.texture = speaker_texture
    else:
        # Use the player character's image
        var player_character: Texture = load(CharacterSingleton.get_character_image())
        speaker_image.texture = player_character

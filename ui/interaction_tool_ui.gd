@warning_ignore("missing_tool")

extends SelectionHighlightVBox

func _ready() -> void:
    InteractionSingleton.interaction_changed.connect(func(interaction):
        selected_index = interaction)
    selected_index = InteractionSingleton.current_interaction

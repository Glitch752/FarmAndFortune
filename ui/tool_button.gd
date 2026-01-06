@tool

extends SizedButton

@export var tool_name: String = "":
    set(name):
        tool_name = name
        _update()

@export var tool_icon: Texture2D:
    set(icon):
        tool_icon = icon
        _update()

@export var color: Color = Color.WHITE:
    set(new_color):
        color = new_color
        _update_color()

@export var interaction: InteractionType = null
func get_interaction_type():
    return interaction

func _ready():
    _update()
    _update_color()
    
    pressed.connect(func():
        get_parent().select(self)
    )

func _update():
    $%Label.label_settings = $%Label.label_settings.duplicate()
    $%Label.text = tool_name
    $%TextureTop.texture = tool_icon
    $%TextureShadow.texture = tool_icon
    
func _update_color():
    $%Label.label_settings.font_color = color
    $%TextureTop.modulate = color

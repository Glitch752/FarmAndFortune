extends VBoxContainer

func _ready():
    if OS.has_feature("release"):
        visible = false

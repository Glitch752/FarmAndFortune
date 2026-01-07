extends TextureRect

func _ready():
    # Pick a random mask to assign
    var mask_index = randi() % 8
    var mask_path = "res://graphics/cropMask/masks/mask_%d.png" % mask_index
    texture = load(mask_path) as Texture2D

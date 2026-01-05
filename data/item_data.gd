class_name ItemData extends Resource

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var description: String

## If this item plants a crop, the crop data
@export var crop: CropData = null
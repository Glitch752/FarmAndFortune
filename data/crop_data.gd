class_name CropData extends Resource

@export var id: StringName
@export var name: String
@export var icon: Texture2D

@export var scene: PackedScene

@export var harvest_items: Array[CropData_HarvestItem] = []

@export var grow_time_seconds: float
@export var wither_time_seconds: float

@export var water_per_minute: float

@export var material: Material
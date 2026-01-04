class_name SeedData extends Resource

@export var id: StringName
@export var harvest_items: Array[SeedData_HarvestItem] = []

@export var grow_time_seconds: float
@export var wither_time_seconds: float

@export var water_per_minute: float

@export var material: Material
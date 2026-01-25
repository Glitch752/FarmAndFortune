# Blegh objects need to be in their own files for serialization to work properly

## Not really "metadata" but whatever at this point
## Stores "small data" / summary info about a save file
class_name SaveFileMetaData extends Resource

@export var name: String = ""
@export var play_time_seconds: float = 0
@export var character: StringName = &"farmer_1"
@export var last_modified: float = 0

# Stats
@export var money: int = 0
@export var gross_earnings: int = 0
@export var total_crops_harvested: int = 0

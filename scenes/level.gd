extends Node2D

func _init():
    # If we directly load into the level scene or create a new save,
    # generate the map and reset appropriately
    MapSingleton._ensure_map_loaded()

func _process(delta: float) -> void:
    # Update play time
    SaveData.play_time_seconds += delta
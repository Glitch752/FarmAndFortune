extends Node2D

func _init():
    # If we directly load into the
    # level scene, we want to make
    # sure we can load a level
    MapSingleton._ensure_map_loaded()

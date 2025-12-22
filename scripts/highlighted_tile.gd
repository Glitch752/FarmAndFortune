extends Label

func _ready():
    InteractionSingleton.highlight_changed.connect(_changed)

func _changed(tile: Vector2i):
    var tile_type = MapSingleton.get_terrain_at(tile)
    text = MapSingleton.TerrainType.keys()[tile_type]

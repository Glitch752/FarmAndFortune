class_name PlantInteraction extends InteractionType

var plant_id: StringName
func _init(_plant_id: StringName):
    plant_id = _plant_id
    
    color = Color(0.5, 1, 0.5)
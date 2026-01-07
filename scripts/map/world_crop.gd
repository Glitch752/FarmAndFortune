class_name WorldCrop

const CROP_PROCESS_INTERVAL = 1.0

var crop: CropData
var node: Node2D

var growth_percentage: float = 0.0
var wither_percentage

func _init(_crop: CropData) -> void:
    crop = _crop

    node = crop.scene.instantiate() as Node2D

## Process this crop.
## Crop processing is spread out over time to avoid performance spikes,
## so adjacent crops aren't necessarily processed in the same frame.
func process():
    # print("Processing crop: %s" % crop.name)
    growth_percentage = max(0, growth_percentage + CROP_PROCESS_INTERVAL / crop.grow_time_seconds)

    node.growth_percentage = growth_percentage

func is_fully_grown() -> bool:
    return growth_percentage >= 1.0

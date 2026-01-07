class_name WorldCrop

const CROP_PROCESS_INTERVAL = 1.0

var crop: CropData
var node: Node2D

func _init(_crop: CropData) -> void:
    crop = _crop

    node = crop.scene.instantiate() as Node2D

## Process this crop.
## Crop processing is spread out over time to avoid performance spikes,
## so adjacent crops aren't necessarily processed in the same frame.
func process():
    # print("Processing crop: %s" % crop.name)
    pass

func is_fully_grown() -> bool:
    return false

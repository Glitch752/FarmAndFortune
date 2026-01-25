class_name WorldCrop

const CROP_PROCESS_INTERVAL = 1.0

var crop: CropData
var node: Node2D

var growth_percentage: float = 0.0
var wither_percentage: float = 0.0

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

# Serialize to the latest data version
func serialize(buffer: StreamPeerBuffer) -> void:
    buffer.put_utf8_string(crop.id)
    buffer.put_float(growth_percentage)
    buffer.put_float(wither_percentage)

# Deserialize from the given data version
static func deserialize(buffer: StreamPeerBuffer, _version: Serialization.WorldDataVersion) -> WorldCrop:
    var crop_id = buffer.get_utf8_string()
    var growth = buffer.get_float()
    var wither = buffer.get_float()
    var crop_data = DataLoader.crops.get(crop_id, null)
    if crop_data == null:
        push_error("Failed to find crop data for id: %s" % crop_id)
        return null
    
    var world_crop = WorldCrop.new(crop_data)
    world_crop.growth_percentage = growth
    world_crop.wither_percentage = wither
    return world_crop

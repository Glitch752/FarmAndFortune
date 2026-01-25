@tool

extends Node2D

@export_tool_button("Recreate")
var recreate = _created

@export_range(0.0, 1.0, 0.01)
var growth_percentage = 0.0:
    set(value):
        growth_percentage = clamp(value, 0.0, 1.0)
        _update_current_stage()

        if not is_node_ready():
            return
        
        _render()

## The length of each growth stage. Items should sum to 1.0
var growth_stage_lengths: PackedFloat32Array = _get_growth_stage_lengths()
func _get_growth_stage_lengths() -> PackedFloat32Array:
    # For some reason, this gets called even though overriding works as intended...
    # whatever
    return PackedFloat32Array()

var growth_stages: PackedFloat32Array = _calculate_growth_stages()

var current_stage: int = 0
func _update_current_stage() -> void:
    for i in range(growth_stages.size() - 1, -1, -1):
        if growth_percentage >= growth_stages[i]:
            current_stage = i
            return

func _calculate_growth_stages() -> PackedFloat32Array:
    var stages = PackedFloat32Array()
    stages.append(0.0)
    var accumulated_percentage = 0.0
    for length in _get_growth_stage_lengths():
        accumulated_percentage += length
        stages.append(accumulated_percentage)
    return stages

## Gets the progress (0.0 to 1.0) through the given stage
## Returns 0.0 if before the stage and 1.0 if after the stage.
func get_stage_progress(stage: int) -> float:
    var stage_start = growth_stages[stage]
    var stage_end = growth_stages[stage + 1]

    if growth_percentage < stage_start:
        return 0.0
    elif growth_percentage >= stage_end:
        return 1.0
    else:
        return (growth_percentage - stage_start) / (stage_end - stage_start)

func _ready() -> void:
    _update_current_stage()
    _render()
    _created()

func _created() -> void:
    pass

func _render() -> void:
    # For some reason, this gets called even though overriding works as intended...
    # whatever
    # push_error("Base crop does not implement _render()")
    pass

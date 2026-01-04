extends Node

## Loads data. wow.
var seeds: Dictionary[String, SeedData] = {}

## Recursively loads all resources under data/[data_type]/**/*.tres
func recursively_load_resources(data_type: String, _type_hint: String = "") -> Array[Resource]:
    var resources: Array[Resource] = []
    var dir = DirAccess.open("res://data/%s" % data_type)
    if dir == null:
        push_error("Failed to open directory for data type: %s" % data_type)
        return resources
    
    dir.list_dir_begin()
    
    var file_name = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            # Recurse into subdirectory
            resources += recursively_load_resources("%s/%s" % [data_type, file_name.get_file()])
        else:
            # Export builds have .remap added to the end of filenames, so strip that off if present
            if file_name.get_extension() == "remap":
                file_name = file_name.replace(".remap", "")
            
            if file_name.get_extension() == "tres":
                # print("Loading resource res://data/%s/%s" % [data_type, file_name])
                var resource = load("res://data/%s/%s" % [data_type, file_name])
                if resource != null:
                    resources.append(resource)
                else:
                    push_error("Failed to load resource: %s" % file_name)
            else:
                print("Skipping non-resource file %s" % file_name)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    return resources

func _ready():
    var loaded_seeds = recursively_load_resources("seeds", "SeedData")
    for seed_res in loaded_seeds:
        if seed_res is SeedData:
            seeds[seed_res.id] = seed_res
        else:
            push_error("Loaded resource is not of type SeedData: %s" % seed_res)
    print("Loaded %d seeds" % seeds.size())
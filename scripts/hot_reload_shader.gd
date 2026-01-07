extends ShaderMaterial

class_name HotReloadShader

## A ShaderMaterial that hot-reloads its shader when the shader file changes on disk (when running a build from the editor).
## When not in the editor, behaves like a normal ShaderMaterial.

func _init():
    if OS.has_feature("editor"):
        var shader_path = shader.resource_path
        
        var watcher = DirectoryWatcher.new()
        watcher.add_scan_directory(shader_path.get_base_dir())
        watcher.files_modified.connect(func(modified_files: PackedStringArray):
            for path in modified_files:
                if path.ends_with(shader_path.get_file()):
                    var new_shader_code = FileAccess.get_file_as_string(shader_path)
                    var new_shader = Shader.new()
                    new_shader.code = new_shader_code
                    shader = new_shader
                    print_rich("[color=yellow]HotReloadShader: Reloaded shader from %s[/color]" % shader_path)
        )
        watcher.scan_delay = 0.3
        
        # This is a resource, so we can't directly add the watcher as a child. This is kind of hacky, but we get the root scene and add it there.
        var root = Engine.get_main_loop().get_root()
        root.add_child.call_deferred(watcher)
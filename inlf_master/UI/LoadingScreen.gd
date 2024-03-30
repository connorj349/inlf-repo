extends Control

export var max_load_time = 10000 # maybe remove
export(Array, String, MULTILINE) var tips # array of tips to display

var rng = RandomNumberGenerator.new() # random tips

func change_scene(path): # need to pass current scene to remove it
	rng.randomize()
	show()
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null: # if the loader can't load anything
		print("Resource loader unable to load the resouce at path")
		return # stop function execution
	
	var t = OS.get_ticks_msec()
	
	if tips and tips.size() > 0:
		var random_index = rng.randi_range(0, tips.size() - 1)
		$Control/VBoxContainer2/TipValue.text = tips[random_index]
	
	var level_name = path.rsplit("/", true, 1)
	var level_name_without_ext = level_name[1].rsplit(".", true, 1)
	$Control/VBoxContainer/LevelName.text = level_name_without_ext[0] # level_list_with_ext[0]
	
	while OS.get_ticks_msec() - t < max_load_time: # run loop until max_load_time has been reached(loading takes too long)
		var err = loader.poll()
		var root_node = get_tree().get_root()
		if err == ERR_FILE_EOF: # loading complete
			for item in get_tree().get_root().get_children():
				if item is Spatial or item is Node2D or item is Control:
					root_node.remove_child(item)
					item.queue_free()
			var resource = loader.get_resource()
			root_node.call_deferred("add_child", resource.instance())
			queue_free() # delete the loading screen
			break # break the loop
		if err == OK: # still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			$ProgressBar.value = progress * 100
		else: # failure to load
			print("Error while loading file")
			break
		yield(get_tree(), "idle_frame") # stop preventing the bar from loading

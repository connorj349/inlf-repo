extends Control

@export var max_load_time = 10000 # maybe remove
@export_multiline var tips: Array[String] # array of tips to display # (Array, String, MULTILINE)

var rng = RandomNumberGenerator.new() # random tips

func change_scene_to_file(path): # need to pass current scene to remove it
	rng.randomize()
	show()
	var loader = ResourceLoader.load_threaded_request(path)
	
	if loader == null: # if the loader can't load anything
		print("Resource loader unable to load the resouce at path")
		return # stop function execution
	
	var t = Time.get_ticks_msec()
	
	if tips and tips.size() > 0:
		var random_index = rng.randi_range(0, tips.size() - 1)
		$MarginContainer/VBoxContainer3/VBoxContainer2/TipValue.text = tips[random_index]
	
	var level_name = path.rsplit("/", true, 1)
	var level_name_without_ext = level_name[1].rsplit(".", true, 1)
	$MarginContainer/VBoxContainer3/VBoxContainer/LevelName.text = level_name_without_ext[0] # level_list_with_ext[0]
	
	while Time.get_ticks_msec() - t < max_load_time: # run loop until max_load_time has been reached(loading takes too long)
		var err = ResourceLoader.load_threaded_get_status(path)
		# the below errors when the player dies too many times and fails, returning to the menu
		# has something to do with the scene not existing when it goes to get the root
		var root_node = get_tree().get_root()
		if err == ResourceLoader.THREAD_LOAD_LOADED: # loading complete
			for item in get_tree().get_root().get_children():
				if item is Node3D or item is Node2D or item is Control:
					root_node.remove_child(item)
					item.queue_free()
			var resource = ResourceLoader.load_threaded_get(path)
			root_node.call_deferred("add_child", resource.instantiate())
			queue_free() # delete the loading screen
			break # break the loop
		if err == ResourceLoader.THREAD_LOAD_IN_PROGRESS: # still loading
			var progress = []
			@warning_ignore("unused_variable")
			var status = ResourceLoader.load_threaded_get_status(path, progress)
			$ProgressBar.value = (progress[0] * 100) * 2
		else: # failure to load
			print("Error while loading file")
			break
		await get_tree().process_frame # stop preventing the bar from loading

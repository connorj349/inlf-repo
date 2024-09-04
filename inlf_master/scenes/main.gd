extends Node

@export var game_scene_path: String

var game_world: Node3D

func _on_game_starting(start_scene_path: String):
	ScreenFader.fade_out()
	
	await $MainMenu.tree_exited
	
	$BGMusic.stop()
	
	game_world = load(game_scene_path).instantiate()
	game_world.scene_path = start_scene_path
	add_child(game_world)
	
	game_world.connect("end_game", Callable(self, "open_main_menu"))
	
	ScreenFader.fade_in()

func open_main_menu():
	ScreenFader.fade_out()
	
	game_world.queue_free()
	
	get_tree().paused = false
	
	# load main menu scene
	var main_menu = load("res://scenes/menu/main_menu.tscn").instantiate()
	add_child(main_menu)
	main_menu.connect("starting", Callable(self, "_on_game_starting"))
	
	$BGMusic.play(0)
	
	ScreenFader.fade_in()

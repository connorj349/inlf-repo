extends Node3D

signal end_game

# this may need to be an array if having multiple SELECTABLE levels
@export var start_scene_path: String

var current_level: Node3D

func _ready():
	current_level = load(start_scene_path).instantiate()
	
	$Levels.add_child(current_level)
	
	current_level.connect("goto_main", Callable(self, "_on_goto_main"))
	
	

func _on_goto_main():
	get_tree().paused = true
	end_game.emit()

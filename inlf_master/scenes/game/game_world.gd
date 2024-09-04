extends Node3D

signal end_game

@export var scene_path: String

var current_level: Node3D

func _ready():
	current_level = load(scene_path).instantiate()
	
	$Levels.add_child(current_level)
	
	current_level.connect("goto_main", Callable(self, "_on_goto_main"))

func _on_goto_main():
	get_tree().paused = true
	end_game.emit()

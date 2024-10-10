extends Control

signal selected_level(level_name: String)

var level_selected = false

func select_level(level_name: String):
	if level_selected:
		return
	
	selected_level.emit(level_name)
	level_selected = true

extends Control
## Level Select
##
## Contains a method and signal for use during level selection in the main menu

signal selected_level(level_name: String)

var level_selected = false

func select_level(level_name: String):
	if level_selected:
		return
	
	selected_level.emit(level_name)
	level_selected = true

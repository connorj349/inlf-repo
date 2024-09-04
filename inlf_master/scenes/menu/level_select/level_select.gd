extends Control

signal selected_level(level_name: String)

func select_level(level_name: String):
	selected_level.emit(level_name)

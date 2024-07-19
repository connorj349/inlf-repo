extends Interactable

@export var money_required_to_end_game: int = 1000

@onready var loading_screen = $LoadingScreen

func _interact(_actor): # end the game
	if Gamestate.bones >= money_required_to_end_game:
		loading_screen.change_scene_to_file("res://scenes/Main.tscn")
	else:
		Globals.emit_signal("on_pop_notification", "Not enough bones to leave the city")

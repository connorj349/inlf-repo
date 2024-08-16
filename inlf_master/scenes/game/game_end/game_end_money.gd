extends Interactable

@export var money_required_to_end_game: int = 1000
@export var game_level: Node3D


func _interact(_actor):
	if Gamestate.bones >= money_required_to_end_game:
		game_level.goto_main.emit()
	else:
		Globals.emit_signal("on_pop_notification", "Not enough bones to leave the city")

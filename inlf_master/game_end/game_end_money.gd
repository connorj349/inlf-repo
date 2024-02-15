extends Interactable

export(int) var money_required_to_end_game = 1000

onready var loading_screen = $LoadingScreen

func _interact(_actor): # end the game
	if Gamestate.can_afford(money_required_to_end_game):
		loading_screen.change_scene("res://scenes/Main.tscn")

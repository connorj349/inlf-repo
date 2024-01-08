extends Interactable

export(int) var money_required_to_end_game = 1000

onready var loading_screen = $LoadingScreen

func _ready():
	Globals.emit_signal("on_pop_notification", "[color=red]I can escape this city with " + str(money_required_to_end_game) + " bones.[/color")

func _interact(_actor): # end the game
	if Gamestate.can_afford(money_required_to_end_game):
		loading_screen.change_scene("res://scenes/Main.tscn")

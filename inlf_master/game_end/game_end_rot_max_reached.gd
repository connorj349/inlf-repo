extends Spatial

onready var loading_screen = $LoadingScreen

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("on_rot_reached_max", self, "rot_reached_max")

func rot_reached_max():
	# add cutscene or other events that play before the player is thrust back into main menu
	loading_screen.change_scene("res://scenes/Main.tscn")

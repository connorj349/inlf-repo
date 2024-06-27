extends Node3D

@onready var loading_screen = $LoadingScreen

var player_stem_cells : set = set_player_stem_cells

func _ready():
	self.player_stem_cells = 10
# warning-ignore:return_value_discarded
	Gamestate.connect("on_player_death", Callable(self, "on_death"))
# warning-ignore:return_value_discarded
	Gamestate.connect("on_player_spawn", Callable(self, "on_spawn"))
# warning-ignore:return_value_discarded
	Gamestate.connect("game_over", Callable(loading_screen, "change_scene_to_file").bind("res://scenes/Menu.tscn"))

func on_death():
	self.player_stem_cells -= 1

func on_spawn(stem_cell_cost):
	self.player_stem_cells -= stem_cell_cost

func set_player_stem_cells(value):
	player_stem_cells = clamp(value, 0, 999)
	Globals.emit_signal("on_pop_notification", "[color=red]Lost 1 stem cell.[/color]")
	Gamestate.emit_signal("on_stem_cells_changed", player_stem_cells)
	if player_stem_cells <= 0:
		Gamestate.emit_signal("game_over")
		# fade out to black screen, display text: YOU RAN OUT OF STEM CELLS
		loading_screen.change_scene_to_file("res://scenes/Menu.tscn")

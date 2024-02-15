extends Spatial

onready var loading_screen = $LoadingScreen

var player_stem_cells setget set_player_stem_cells

func _ready():
	self.player_stem_cells = 10
# warning-ignore:return_value_discarded
	Gamestate.connect("on_player_death", self, "on_death")
# warning-ignore:return_value_discarded
	Gamestate.connect("on_player_spawn", self, "on_spawn")

func on_death():
	self.player_stem_cells -= 1

func on_spawn(stem_cell_cost):
	self.player_stem_cells -= stem_cell_cost

func set_player_stem_cells(value):
	player_stem_cells = clamp(value, 0, 999)
	Globals.emit_signal("on_pop_notification", "[color=red]Lost 1 stem cell.[/color]")
	Gamestate.emit_signal("on_stem_cells_changed", player_stem_cells)
	if player_stem_cells <= 0:
		loading_screen.change_scene("res://scenes/Main.tscn")

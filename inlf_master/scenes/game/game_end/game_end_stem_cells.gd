extends Level

signal stem_cells_changed(stem_cells_remaining: int)

var player_stem_cells : set = set_player_stem_cells

func _ready():
	self.player_stem_cells = 10

func handle_player_death():
	self.player_stem_cells -= 1

func handle_player_spawn(stem_cell_cost):
	self.player_stem_cells -= stem_cell_cost

func set_player_stem_cells(value):
	player_stem_cells = clamp(value, 0, 999)
	
	if player_stem_cells <= 0:
		goto_main.emit()
		return
	
	Globals.emit_signal("on_pop_notification", "[color=red]Lost 1 stem cell.[/color]")
	
	stem_cells_changed.emit(player_stem_cells)

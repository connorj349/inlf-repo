extends Level

signal stem_cells_changed(stem_cells_remaining: int)
signal rot_changed
signal infections_count_changed

@export var rot_max_value: int = 1000

var rot: int = 0 :
	set(value):
		rot = clamp(value, 0, Globals.rot_max_value)
		if rot >= Globals.rot_max_value:
			goto_main.emit()
		emit_signal("rot_changed")

var bloaters: int = 0 :
	set(value):
		bloaters = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var tumors: int = 0 :
	set(value):
		tumors = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var infections: int :
	get:
		return bloaters + tumors

var player_stem_cells : set = set_player_stem_cells

func _ready():
	self.player_stem_cells = 10
	for rot_object in get_tree().get_nodes_in_group("rot_producers"):
		rot_object.connect("increase_rot", Callable(func(arg): self.rot += arg))
	
	for rot_reducer in get_tree().get_nodes_in_group("rot_reducers"):
		rot_reducer.connect("reduce_rot", Callable(func(arg): self.rot -= arg))

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

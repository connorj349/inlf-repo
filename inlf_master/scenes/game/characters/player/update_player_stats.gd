extends PanelContainer

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("bones_changed", Callable(self, "update_bones_text"))
	get_tree().current_scene.game_world.current_level.connect("stem_cells_changed", Callable(self, "update_stems_text"))
	update_bones_text(Gamestate.bones)

func update_bones_text(value):
	$MarginContainer/VBoxContainer/bones.text = "bones: " + str(value)

func update_stems_text(value):
	$MarginContainer/VBoxContainer/stems.text = "stem cells: " + str(value)

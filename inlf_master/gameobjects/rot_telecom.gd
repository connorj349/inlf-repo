extends Interactable

@onready var percent = $CanvasLayer/Info/VBoxContainer/RotPercentage
@onready var infections = $CanvasLayer/Info/VBoxContainer/Infections

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("rot_changed", Callable(self, "update_text"))
# warning-ignore:return_value_discarded
	Gamestate.connect("infections_count_changed", Callable(self, "update_text"))
	@warning_ignore("integer_division")
	percent.text = "Rot: " + str(Gamestate.rot/Globals.rot_max_value) + "%"

func update_text(): #each time rot is increase/cancer machines are made, this is called to update screen
	percent.text = "Rot: " + "%s%%" % [round(((float(Gamestate.rot) / Globals.rot_max_value)) * 100)]
	infections.text = "Infections: " + str(Gamestate.infections)

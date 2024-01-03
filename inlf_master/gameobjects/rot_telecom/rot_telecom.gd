extends Interactable

onready var percent = $CanvasLayer/Info/VBoxContainer/RotPercentage

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("rot_changed", self, "update_text")
	percent.text = "Rot: " + str(Gamestate.rot/Globals.rot_max_value) + "%"

func update_text(): #each time rot is increase/cancer machines are made, this is called to update screen
	percent.text = "Rot: " + "%s%%" % [round(((float(Gamestate.rot) / Globals.rot_max_value)) * 100)]

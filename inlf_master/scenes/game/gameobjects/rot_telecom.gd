extends Interactable

@export var info_label: Label

@onready var update_sound: AudioStreamPlayer3D = $UpdateSound

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("rot_changed", Callable(self, "update_text"))
# warning-ignore:return_value_discarded
	Gamestate.connect("infections_count_changed", Callable(self, "update_text"))
	@warning_ignore("integer_division")
	info_label.text = "Rot: " + str(Gamestate.rot/Globals.rot_max_value) + "%" + "\n" + "Infections: " + str(Gamestate.infections)

func update_text(): # each time rot is increase/cancer machines are made, this is called to update screen
	info_label.text = "Rot: " + "%s%%" % [round(((float(Gamestate.rot) / Globals.rot_max_value)) * 100)] + "\n" + "Infections: " + str(Gamestate.infections)
	update_sound.play()

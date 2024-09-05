extends Interactable

@export var info_label: Label

@onready var current_level = get_tree().current_scene.game_world.current_level
@onready var update_sound: AudioStreamPlayer3D = $UpdateSound

func _ready():
# warning-ignore:return_value_discarded
	current_level.connect("rot_changed", Callable(self, "update_text"))
# warning-ignore:return_value_discarded
	current_level.connect("infections_count_changed", Callable(self, "update_text"))
	@warning_ignore("integer_division")
	info_label.text = "Rot: " + str(current_level.rot/current_level.rot_max_value) + "%" + "\n" + "Infections: " + str(current_level.infections)

# each time rot is increase/cancer machines are made, this is called to update screen
func update_text():
	info_label.text = "Rot: " + "%s%%" % [round(((float(current_level.rot) / current_level.rot_max_value)) * 100)] + "\n" + "Infections: " + str(current_level.infections)
	update_sound.play()

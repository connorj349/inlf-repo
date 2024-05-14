extends HSlider

export var audio_bus_name = "Master"

onready var _bus = AudioServer.get_bus_index(audio_bus_name)

func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(_bus))

func _on_value_changed(_value):
	AudioServer.set_bus_volume_db(_bus, linear2db(_value))

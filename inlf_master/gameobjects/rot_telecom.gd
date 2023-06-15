extends Interactable

# add a sound for when rot reaches critical thresholds(0, 25, 50, 75, 100)
# add text that shows what current labor/sales taxes are

onready var percent = $CanvasLayer/Info/VBoxContainer/RotPercentage
onready var count = $CanvasLayer/Info/VBoxContainer/CancersCount

func _ready():
# warning-ignore:return_value_discarded
	Gamestate.connect("rot_changed", self, "update_text")
	percent.text = "Rot: " + str(Gamestate.rot) + "%"
	count.text = "" #make count not do anything for now

func update_text(): #each time rot is increase/cancer machines are made, this is called to update screen
	percent.text = "Rot: " + str(Gamestate.rot) + "%"

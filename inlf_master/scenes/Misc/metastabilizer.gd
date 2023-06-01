extends Interactable

# add a repair sound
# add a semi-quiet looping operating sound, so the player can tell by sound alone this is functional
# add a sound that triggers when rot is reduced/additional sound for when rot is increased on infected
# add infected capabilities

export(Resource) var repair_item
export(int) var heal_amount = 25

onready var health = $Health
onready var bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var status_label = $CanvasLayer/Info/VBoxContainer/Label

var active = true

func _ready():
	health.init()
	bar.init(health.health, health.max_health)
	health.connect("health_changed", bar, "update_bar")
	health.connect("dead", self, "on_disable")
	status_label.text = "Status: operational"

func _interact(_actor):
	if Gamestate.player_inventory.take_item(repair_item):
		health.heal(heal_amount)

func on_disable():
	active = false
	status_label.text = "Status: disabled"

func _on_Timer_timeout():
	# if infected, increase rot; if repaired, decrease rot
	if active:
		health.hurt(1) #decrease health constantly
		if health.health > 0:
			status_label.text = "Status: operational"
			Gamestate.rot_modify(-1)

extends Interactable

export(Resource) var repair_item_data

onready var health = $Health
onready var bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var status_label = $CanvasLayer/Info/VBoxContainer/Label
onready var spot_light = $SpotLight

var active = true

func _ready():
	health.init()
	bar.init(health.health, health.max_health)
	health.connect("health_changed", bar, "update_bar")
	health.connect("dead", self, "on_disable")
	status_label.text = "Status: operational"

func on_hurt(damage):
	if damage.type != Damage.DamageType.Fists:
		health.health -= damage.amount # take damage from non Fists sources

func on_disable():
	spot_light.light_color = Color(1, 0, 0, 1)
	active = false
	status_label.text = "Status: disabled"

func _on_Timer_timeout():
	if active:
		if health.health > 0:
			status_label.text = "Status: operational"
			Gamestate.rot -= 1
			health.health -= 1

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if body.slot_data.item_data == repair_item_data:
			health.health += Globals.meta_repair_amount
			Gamestate.bones += Globals.meta_repair_reward_amount
			body.queue_free()
			$ItemAddedSound.play()
			if not active:
				active = true
				spot_light.light_color = Color(0, 0.9, 1, 1)

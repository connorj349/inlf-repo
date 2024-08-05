extends Interactable

@export var repair_item_data: ItemData
@export var bar: ProgressBar
@export var status_label: Label

var active = true

@onready var health = $Health
@onready var spot_light = $SpotLight3D

func _ready():
	health.init()
	bar.init(health.health, health.max_health)
	health.connect("health_changed", Callable(bar, "update_bar"))
	health.connect("dead", Callable(self, "on_disable"))
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

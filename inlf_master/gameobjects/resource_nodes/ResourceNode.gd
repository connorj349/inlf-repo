extends Interactable

export(Resource) var slot_data #resource item to drop on death
export(String) var display_name = "NULL" #what to display on nameplate
export(Array, Damage.DamageType) var blocked_damage_types

onready var health = $Health
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar

var item_prefab = preload("res://item/pick_up/Pickup.tscn")
var dead = false

func _ready():
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	name_plate.text = display_name
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_death(): #spawn item, delete self
	dead = true
	# play the break effect
	# turn model visible = false
	yield(health.death_sound, "finished") #wait until the death sound is finished
	Globals.create_pickup(slot_data, self)
	queue_free() #destroy

# change to: on_hurt(damage, dealer = null) this is because the dealer may not be passed, passed only for player
func on_hurt(damage):
	if dead:
		return
	# match(damage.damage_type) for each type, block damage X% of the time
	# if the damage type is fists, 50% of the time block it, then also always deal damage to the dealer/player
	health.hurt(damage.amount)

extends Interactable

export(Resource) var slot_data #resource item to drop on death
export(String) var display_name = "NULL" #what to display on nameplate
export(Array, Damage.DamageType) var blocked_damage_types
export(bool) var punching_hurts = false

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
	randomize()

func on_death(): #spawn item, delete self
	dead = true
	# play the break effect
	# turn model visible = false
	yield(health.death_sound, "finished") #wait until the death sound is finished
	Globals.create_pickup(slot_data, self)
	queue_free() #destroy

func on_hurt(damage):
	if dead:
		return
	var random_result = randf()
	for damage_type in blocked_damage_types:
		if damage.type == Damage.DamageType.Fists:
			if punching_hurts:
				Globals.current_player.on_hurt(damage) #replace with damage from this object
			health.hurt(damage.amount) #always damage the resource_node with fists, but hurt player
			return
		elif damage.type == damage_type:
			if random_result < 0.5: #fifty percent chance to deal damage to object
				health.hurt(damage.amount)
				return
		else:
			health.hurt(damage.amount) #deal damage to object

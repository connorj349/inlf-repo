extends Interactable

# needs to be slot data
export(Resource) var common_organ
export(Resource) var uncommon_organ
export(Resource) var rare_organ

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var organ_spawn = $organ_spawnpoint

onready var big_flesh = $flesh_large
var blood_spray = preload("res://effects/blood_spray.tscn")
var corpse_damage = Damage.new()
var inventory = InventoryData.new()

func _ready():
	corpse_damage.amount = 1
	corpse_damage.type = Damage.DamageType.Blunt
	randomize()
	# spawn gib effects and blood effects to simulate corpse explosion after death
	health.init()
	health.connect("health_changed", prog_bar, "update_bar")
	health.connect("dead", self, "queue_free")
	#maybe make a death blood explosion? this could be useful for the interact that will just call on_death
	prog_bar.init(health.health, health.max_health)
	state_text.text = "Fresh"
	spawn_blood()

func init_inventory_size(size):
	inventory.slot_datas.resize(size)

func on_hurt(damage):
	match(damage):
		Damage.DamageType.Sharp:
			spawn_organ()
			big_flesh.visible = false
		_:
			health.health -= damage.amount

func _interact(_actor):
	if can_interact:
		if health.health > 75:
			_actor.on_heal(25)
			big_flesh.visible = false
			spawn_blood()
			on_hurt(75)
		if inventory.slot_datas > 0:
			Globals.create_pickup(inventory.slot_datas[0]) # choose random index, give item
			inventory.take_item(inventory.slot_datas[0])
			Globals.current_player.health.pox += 5
			# Globals.current_player.dispair += 10

func spawn_blood():
	var blood = blood_spray.instance()
	add_child(blood)
	blood.global_transform.origin = self.global_transform.origin

func _on_DecayTimer_timeout():
	on_hurt(corpse_damage)
	Gamestate.rot_modify(1)
	if health.health > 75:
		state_text.text = "Fresh"
	elif health.health < 75 and health.health > 25:
		state_text.text = "Rotting"
	elif health.health < 25:
		state_text.text = "Husk"

func spawn_organ():
	var random_result = randf()
	if random_result < 0.8:
		Globals.create_pickup(common_organ, organ_spawn)
	elif random_result < 0.95:
		Globals.create_pickup(uncommon_organ, organ_spawn)
	else:
		Globals.create_pickup(rare_organ, organ_spawn)

extends Interactable

# needs to be slot data
export(Resource) var common_organ
export(Resource) var uncommon_organ
export(Resource) var rare_organ

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var organ_spawn = $organ_spawnpoint

var blood_spray = preload("res://effects/blood_spray.tscn")
var corpse_damage = Damage.new()
var corpse_eat_damage = Damage.new()
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
	corpse_eat_damage.amount = health.max_health * 0.5
	spawn_blood()

func init_inventory_size(size):
	inventory.slot_datas.resize(size)

func on_hurt(damage):
	match(damage):
		Damage.DamageType.Sharp:
			spawn_organ()
		_:
			health.health -= damage.amount
	if health.health > health.max_health * 0.9:
		state_text.text = "fresh"
	elif health.health < health.max_health * 0.9 and health.health > health.max_health * 0.25:
		state_text.text = "rotting"
	elif health.health < health.max_health * 0.25:
		state_text.text = "husk"

func _interact(_actor):
	if can_interact:
		if health.health > health.max_health * 0.5:
			_actor.on_heal(25)
			spawn_blood()
			on_hurt(corpse_eat_damage)
			Globals.current_player.health.pox += 5
		if inventory.slot_datas.size() > 0:
			for item in inventory.slot_datas:
				if item:
					Globals.create_pickup(item) # choose random index, give item
					inventory.take_item(item)
					# Globals.current_player.health.pox += 5
					# Globals.current_player.dispair += 10
					return

func spawn_blood():
	var blood = blood_spray.instance()
	add_child(blood)
	blood.global_transform.origin = self.global_transform.origin

func _on_DecayTimer_timeout():
	on_hurt(corpse_damage)
	Gamestate.rot += 1

func spawn_organ():
	var random_result = randf()
	if random_result < 0.8:
		Globals.create_pickup(common_organ, organ_spawn)
	elif random_result < 0.95:
		Globals.create_pickup(uncommon_organ, organ_spawn)
	else:
		Globals.create_pickup(rare_organ, organ_spawn)

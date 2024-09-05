extends Interactable

signal increase_rot(amount: int)

# needs to be slot data
@export var common_organ: ItemData
@export var uncommon_organ: ItemData
@export var rare_organ: ItemData
@export var blood_spray: PackedScene
@export var prog_bar: ProgressBar
@export var state_text: Label

var corpse_damage = Damage.new()
var corpse_eat_damage = Damage.new()
var inventory = InventoryData.new()

@onready var health = $Health
@onready var organ_spawn = $organ_spawnpoint

func _ready():
	if !is_in_group("rot_producers"):
		add_to_group("rot_producers")
	
	corpse_damage.amount = 1
	corpse_damage.type = Damage.DamageType.Blunt
	
	randomize()
	
	# spawn gib effects and blood effects to simulate corpse explosion after death
	health.init()
	health.connect("health_changed", Callable(prog_bar, "update_bar"))
	health.connect("dead", Callable(self, "queue_free"))
	
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

func _interact(actor):
	if can_interact:
		# need to rewrite how eating corpses work
		if health.health > health.max_health * 0.5:
			actor.on_heal(25)
			spawn_blood()
			on_hurt(corpse_eat_damage)
			actor.health.pox += 5
		
		if inventory.slot_datas.size() > 0:
			for item in inventory.slot_datas:
				if item:
					var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
					new_pickup.slot_data = item
					get_tree().current_scene.game_world.add_child(new_pickup)
					new_pickup.global_transform.origin = $organ_spawnpoint.global_transform.origin
					inventory.take_item(item)
					actor.health.pox += 5
					# actor.dispair += 10
					return

func spawn_blood():
	var blood = blood_spray.instantiate()
	add_child(blood)
	blood.global_transform.origin = self.global_transform.origin

func _on_DecayTimer_timeout():
	on_hurt(corpse_damage)
	increase_rot.emit(1)

func spawn_organ():
	var new_slot_data = SlotData.new()
	var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
	get_tree().current_scene.game_world.add_child(new_pickup)
	new_pickup.global_transform.origin = $organ_spawnpoint.global_transform.origin
	
	var random_result = randf()
	if random_result < 0.8:
		new_slot_data.item_data = common_organ
		new_pickup.slot_data = new_slot_data
	elif random_result < 0.95:
		new_slot_data.item_data = uncommon_organ
		new_pickup.slot_data = new_slot_data
	else:
		new_slot_data.item_data = rare_organ
		new_pickup.slot_data = new_slot_data

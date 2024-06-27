extends CharacterBody3D

enum STATE { IDLE, PATROL, ATTACK }

@export var inventory_data: Resource
@export var loot_table: Array[ItemData] # (Array, Resource)
@export var will_retaliate: bool = false

@onready var health = $Health

var current_state = STATE.IDLE
var target = null

func _ready():
	randomize()
	health.init()
	health.connect("dead", Callable(self, "kill"))
	randomize_loot()

func _process(delta):
	match(current_state):
		STATE.IDLE:
			process_idle_state(delta)
		STATE.PATROL:
			process_patrol_state(delta)
		STATE.ATTACK:
			process_attack_state(delta)

func on_hurt(damage):
	health.health -= damage.amount
	if damage.source and will_retaliate:
		target = damage.source
		current_state = STATE.ATTACK

# warning-ignore:unused_argument
func process_idle_state(_delta):
	# move to starting position
	pass

# warning-ignore:unused_argument
func process_patrol_state(_delta):
	# choose random patrol point in PatrolPoints node and move to it
	pass

# warning-ignore:unused_argument
func process_attack_state(_delta):
	# if target is valid, move within attack range and perform attack based on accuracy(if ranged)
	pass

func kill():
	var corpse = Globals.create_corpse(self)
	corpse.global_transform.origin = global_transform.origin
	corpse.init_inventory_size(inventory_data.slot_datas.size())
	for item in inventory_data.slot_datas:
		if item:
			corpse.inventory.add_item(item)
	queue_free()

func randomize_loot():
	var random_amount = randi() % loot_table.size()
	for _i in range(0, random_amount):
		var new_slot = SlotData.new()
		var random_item = loot_table[randi() % loot_table.size()] # choose a random item
		new_slot.item_data = random_item
		inventory_data.add_item(new_slot)

func _on_Area_body_entered(body):
	target = body

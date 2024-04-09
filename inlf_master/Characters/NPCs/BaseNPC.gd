extends KinematicBody

export(Resource) var inventory_data
export(Array, Resource) var loot_table

onready var health = $Health

func _ready():
	randomize()
	health.init()
	health.connect("dead", self, "kill")
	randomize_loot()

func on_hurt(damage):
	health.health -= damage.amount

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

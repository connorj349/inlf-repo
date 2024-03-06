extends Interactable
class_name Storage

signal toggle_inventory(external_inventory_owner)

export(Resource) var inventory_data
export(Array, Resource) var item_datas # change to loot_table
export(float) var reset_time = 300.0 # time until the inventory resets itself; default to 5 minutes
export(bool) var does_reset = false # determines if this storage container will reset its inventory and repopulate with new

onready var sound_queue = $SoundQueue

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	connect("toggle_inventory", Globals, "toggle_inventory_interface") # need to do this or else wont work on lvl chg

func _interact(_actor):
	sound_queue.PlaySound()
	emit_signal("toggle_inventory", self)

func _on_Timer_timeout():
	if does_reset:
		$Timer.wait_time = reset_time
		for item in inventory_data.slot_datas: # remove each item within the inventory
			if item:
				inventory_data.take_item(item)
		
		var random_amount = randi() % item_datas.size()
		for _i in range(0, random_amount):
			var new_slot = SlotData.new()
			var random_item = item_datas[randi() % item_datas.size()] # choose a random item
			new_slot.item_data = random_item
			inventory_data.add_item(new_slot)
	else:
		$Timer.one_shot = true

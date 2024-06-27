extends Interactable
class_name Storage

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: Resource
@export var item_datas: Array[ItemData] # change to loot_table # (Array, Resource)
@export var reset_time: float = 300.0 # time until the inventory resets itself; default to 5 minutes
@export var does_reset: bool = false # determines if this storage container will reset its inventory and repopulate with new

@onready var sound_queue = $SoundQueue

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	connect("toggle_inventory", Callable(Globals, "toggle_inventory_interface")) # need to do this or else wont work on lvl chg

func _interact(_actor):
	sound_queue.PlaySound()
	emit_signal("toggle_inventory", self)

func _on_Timer_timeout():
	if does_reset and item_datas.size() > 0:
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

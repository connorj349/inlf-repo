extends Interactable
class_name Storage

# add a subset of storages that can has a chance to "lose/have stolen" from after set amount of time
# after not being interacted with
# make it so that storages can auto-populate with items/random loot

signal toggle_inventory(external_inventory_owner)

export(Resource) var inventory_data
export(Array, Resource) var items

func _ready():
# warning-ignore:return_value_discarded
	connect("toggle_inventory", Globals, "toggle_inventory_interface") # need to do this or else wont work on lvl chg
	if items.size() <= inventory_data.slot_datas.size():
		for item in items:
			if item:
				inventory_data.add_item(item)

func _interact(_actor):
	emit_signal("toggle_inventory", self)

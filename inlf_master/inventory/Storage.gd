extends Interactable
class_name Storage

# add a subset of storages that can has a chance to "lose/have stolen" from after set amount of time
# after not being interacted with
# make it so that storages can auto-populate with items/random loot, this loot disappears after awhile

signal toggle_inventory(external_inventory_owner)

export(Resource) var inventory_data

func _interact(_actor):
	emit_signal("toggle_inventory", self)

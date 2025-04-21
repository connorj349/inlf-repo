extends Mutation
class_name MutationWeapon

@export var weapon_item_data: ItemDataWeapon

func apply(player):
	var new_slot_data = SlotData.new()
	new_slot_data.item_data = weapon_item_data
	player.inventory_data.add_item(new_slot_data)

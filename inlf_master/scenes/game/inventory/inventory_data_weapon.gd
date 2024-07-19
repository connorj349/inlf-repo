extends InventoryData
class_name InventoryDataWeapon

func drop_slot_data(grabbed_slot_data, index):
	
	if not grabbed_slot_data.item_data is ItemDataWeapon:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)

func drop_single_slot_data(grabbed_slot_data, index):
	
	if not grabbed_slot_data.item_data is ItemDataWeapon:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)

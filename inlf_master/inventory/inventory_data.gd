extends Resource
class_name InventoryData

signal inventory_updated(inventory_data)
signal inventory_interact(inventory_data, index, button)

export(Array, Resource) var slot_datas

func grab_slot_data(index):
	var slot_data = slot_datas[index]
	
	if slot_data:
		slot_datas[index] = null
		emit_signal("inventory_updated", self)
		return slot_data
	else:
		return null

func drop_slot_data(grabbed_slot_data, index): #dropping the grabbed item into a slot in inv
	var slot_data = slot_datas[index]
	
	var return_slot_data: SlotData = null
	if slot_data and slot_data.can_fully_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data)
		# SoundManager.play_merge
	else:
		slot_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
		# SoundManager.play_drop_new_slot
	
	emit_signal("inventory_updated", self)
	return return_slot_data

func drop_single_slot_data(grabbed_slot_data, index): #dropping single item count into slot in inv OR creating new slot
	var slot_data = slot_datas[index]
	if not slot_data:
		slot_datas[index] = grabbed_slot_data.create_single_slot_data()
	elif slot_data.can_merge_with(grabbed_slot_data):
		slot_data.fully_merge_with(grabbed_slot_data.create_single_slot_data())
	
	emit_signal("inventory_updated", self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func use_slot_data(index): #use up the item, then apply effects to player
	var slot_data = slot_datas[index]
	
	if not slot_data:
		return
	
	if slot_data.item_data is ItemDataConsumable or slot_data.item_data is ItemDataOrgan:
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			slot_datas[index] = null
	
	Globals.current_player.use_slot_data(slot_data) #use the item on the player
	emit_signal("inventory_updated", self)

func buy_slot_data(index): # use money to put item from vendor inv directly into player inventory
	var slot_data = slot_datas[index]
	var new_added_slot_data
	
	if not slot_data:
		return
	
	if Gamestate.bones >= slot_data.item_data.price:
		Gamestate.bones -= slot_data.item_data.price
		Globals.emit_signal("on_pop_notification", "I bought %s, I now have %s bones." % [slot_data.item_data.name, Gamestate.bones])
		new_added_slot_data = slot_data.duplicate() #creating a new item to be put into player inventory
		new_added_slot_data.quantity = 1
		slot_data.quantity -= 1 #reducing what's left in the actual inventory
		if slot_data.quantity < 1:
			slot_datas[index] = null
		Gamestate.player_inventory.add_item(new_added_slot_data) # adding the new item to player inv
		emit_signal("inventory_updated", self) #updating the merchant inventory list ui menu
	else:
		Globals.emit_signal("on_pop_notification", "I cant afford %s right now." % slot_data.item_data.name)

func pick_up_slot_data(slot_data): #pickup and put into inventorydata; returns true/false
	for index in slot_datas.size():
		if slot_datas[index] and slot_datas[index].can_fully_merge_with(slot_data):
			slot_datas[index].fully_merge_with(slot_data)
			emit_signal("inventory_updated", self)
			return true
	
	for index in slot_datas.size():
		if not slot_datas[index]:
			slot_datas[index] = slot_data
			emit_signal("inventory_updated", self)
			return true
	
	return false

func add_item(slot_data):
	for index in slot_datas.size(): #iterate X times where X is the inventories' size
		if slot_datas[index]: # if the item already exists within this inventory
			if slot_datas[index].can_fully_merge_with(slot_data): #try to merge with existing data
				slot_datas[index].fully_merge_with(slot_data) #merge
				emit_signal("inventory_updated", self) #emit signals
				return #immediately stop
		else: # if there is an open spot available
			var new_slot = slot_data.duplicate() #duplicate the data
			slot_datas[index] = new_slot #create a new slot equal to the data
			emit_signal("inventory_updated", self)
			return

func take_item(slot_data): #take a specific item from the player's inventory
	if slot_data == null:
		return
	for index in slot_datas.size():
		if slot_datas[index]: #if there is data in this slot per index
			if slot_datas[index].item_data == slot_data.item_data and slot_datas[index].quantity >= slot_data.quantity:
				slot_datas[index].quantity -= slot_data.quantity
				if slot_datas[index].quantity < 1:
					slot_datas[index] = null
				emit_signal("inventory_updated", self)
				return true #returns true if successful
	return false #returns false if not successful

func on_slot_clicked(index, button):
	emit_signal("inventory_interact", self, index, button)

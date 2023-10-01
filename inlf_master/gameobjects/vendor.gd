extends Interactable

const Slot = preload("res://inventory/inventory_slot.tscn")

onready var panel = $CanvasLayer/Control/PanelContainer
onready var merchant_list = $CanvasLayer/Control/PanelContainer/MarginContainer/GridContainer

func _ready():
	set_inventory_data(Gamestate.merchant_inventory)
# warning-ignore:return_value_discarded
	Globals.connect("on_inventory_toggle", self, "toggle_window")

func _interact(_actor):
	panel.show()
	Globals.current_ui.show()
	if panel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func toggle_window():
	#if Globals.current_ui.visible:
	panel.hide()

func set_inventory_data(inventory_data: InventoryData):
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_updated", self, "populate_item_list")
	populate_item_list(inventory_data)
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_interact", self, "buy_item")

func populate_item_list(inventory_data: InventoryData):
	for child in merchant_list.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instance()
		merchant_list.add_child(slot)
		
		slot.connect("slot_clicked", inventory_data, "on_slot_clicked")
		
		if slot_data:
			slot.set_slot_data(slot_data)

func buy_item(inventory_data, index, button):
	match [button]:
		[BUTTON_LEFT]: # try to buy the item in the slot at index
			inventory_data.buy_slot_data(index)
			#for extra immersion, maybe put more pop notifications here for if player can't buy item or
			#when the player is successful
		[BUTTON_RIGHT]: # display the name and price of the item
			if inventory_data.slot_datas[index]:
				Globals.emit_signal("on_pop_notification", "%s is worth %s bones." % [inventory_data.slot_datas[index].item_data.name, inventory_data.slot_datas[index].item_data.price])

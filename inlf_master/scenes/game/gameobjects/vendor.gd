extends Interactable

@export var Slot: PackedScene

var merchant_inventory: InventoryData

@onready var panel = $CanvasLayer/Control/PanelContainer
@onready var merchant_list = $CanvasLayer/Control/PanelContainer/MarginContainer/GridContainer
@onready var use_sound: AudioStreamPlayer3D = $UseSound
@onready var buy_sound: AudioStreamPlayer3D = $BuySound

func _ready():
	merchant_inventory = InventoryData.new()
	merchant_inventory.slot_datas.resize(18)
	
	set_inventory_data(merchant_inventory)
	
# warning-ignore:return_value_discarded
	Globals.connect("on_inventory_toggle", Callable(self, "toggle_window"))

func _interact(_actor):
	panel.show()
	
	Globals.current_ui.show()
	
	if panel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		use_sound.play()

func toggle_window():
	panel.hide()

func set_inventory_data(inventory_data: InventoryData):
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_updated", Callable(self, "populate_item_list"))
	
	populate_item_list(inventory_data)
	
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_interact", Callable(self, "buy_item"))

func populate_item_list(inventory_data: InventoryData):
	for child in merchant_list.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		merchant_list.add_child(slot)
		
		slot.connect("slot_clicked", Callable(inventory_data, "on_slot_clicked"))
		
		if slot_data:
			slot.set_slot_data(slot_data)

func buy_item(inventory_data, index, button):
	match [button]:
		[MOUSE_BUTTON_LEFT]: # try to buy the item in the slot at index
			inventory_data.buy_slot_data(index)
			
			buy_sound.play()
		[MOUSE_BUTTON_RIGHT]: # display the name and price of the item
			if inventory_data.slot_datas[index]:
				Globals.emit_signal("on_pop_notification", "%s is worth %s bones." % [inventory_data.slot_datas[index].item_data.name, inventory_data.slot_datas[index].item_data.price])

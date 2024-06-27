extends PanelContainer

signal hot_bar_use(index)

const Slot = preload("res://inventory/inventory_slot.tscn")

@onready var h_box_container = $MarginContainer/HBoxContainer

func _ready():
	set_inventory_data(Gamestate.player_inventory)
# warning-ignore:return_value_discarded
	Globals.connect("on_inventory_toggle", Callable(self, "toggle_hotbar"))

func _unhandled_key_input(event):
	if not visible or not event.is_pressed():
		return
	
	if range(KEY_1, KEY_7).has(event.keycode):
		emit_signal("hot_bar_use", event.keycode - KEY_1)

func toggle_hotbar():
	if Globals.current_ui.visible:
		hide()
	else:
		show()

func set_inventory_data(inventory_data: InventoryData):
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_updated", Callable(self, "populate_hot_bar"))
	populate_hot_bar(inventory_data)
# warning-ignore:return_value_discarded
	connect("hot_bar_use", Callable(inventory_data, "use_slot_data"))

func populate_hot_bar(inventory_data: InventoryData):
	for child in h_box_container.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas.slice(0, 5):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)

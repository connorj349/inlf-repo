extends PanelContainer

const Slot = preload("res://scenes/game/inventory/inventory_slot.tscn")

@onready var item_grid = $MarginContainer/ItemGrid

func set_inventory_data(inventory_data: InventoryData):
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_updated", Callable(self, "populate_item_grid"))
	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData):
# warning-ignore:return_value_discarded
	inventory_data.disconnect("inventory_updated", Callable(self, "populate_item_grid"))

func populate_item_grid(inventory_data: InventoryData):
	for child in item_grid.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.connect("slot_clicked", Callable(inventory_data, "on_slot_clicked"))
		
		if slot_data:
			slot.set_slot_data(slot_data)

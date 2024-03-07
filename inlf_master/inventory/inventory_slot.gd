extends PanelContainer

signal slot_clicked(index, button)

onready var texture_rect = $MarginContainer/TextureRect
onready var quantity_label = $QuantityLabel

func set_slot_data(slot_data: SlotData):
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	#hint_tooltip = "%s\n%s" % [item_data.name, item_data.description]
	$ToolTip._visuals.get_node("Label").text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_inventory_slot_gui_input(event: InputEvent):
	if event is InputEventMouseButton \
			and (event.button_index == BUTTON_LEFT \
			or event.button_index == BUTTON_RIGHT) \
			and event.is_pressed():
		emit_signal("slot_clicked", get_index(), event.button_index)

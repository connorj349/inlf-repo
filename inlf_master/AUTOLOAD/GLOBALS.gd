extends Node

# warning-ignore:unused_signal
signal on_inventory_toggle
# warning-ignore:unused_signal
signal on_pop_notification

const pickup = preload("res://scenes/game/item/pick_up/pickup.tscn")
const corpse = preload("res://scenes/game/characters/corpse.tscn")
# global value that may be able to be changed by the player at runtime for diff setting?
const rot_max_value = 1000

# allows other objects to reference the player like setting target/etc.
var current_player
# player inventory global reference for other scripts
var current_ui

func _ready():
	#begin game with mouse mode captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
# warning-ignore:return_value_discarded
	connect("on_inventory_toggle", Callable(self, "toggle_inventory_interface"))

func toggle_inventory_interface(external_inventory_owner = null):
	if current_ui:
		current_ui.visible = !current_ui.visible #toggle player inventory menu
	
	if current_ui.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if external_inventory_owner and current_ui.visible:
		current_ui.set_external_inventory(external_inventory_owner)
	else:
		current_ui.clear_external_inventory()

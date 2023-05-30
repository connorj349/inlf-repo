extends Node

# change create_pickup to accept an object to adjust where it places the new created pickup

const pickup = preload("res://item/pick_up/Pickup.tscn")

var current_player #allows other objects to reference the player like setting target/etc.
var current_ui #player inventory global reference for other scripts

# warning-ignore:unused_signal
signal on_inventory_toggle

func _ready():
	#begin game with mouse mode captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# warning-ignore:return_value_discarded
	connect("on_inventory_toggle", self, "toggle_inventory_interface")
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.connect("toggle_inventory", self, "toggle_inventory_interface")

func _process(_delta):
	#debug close out
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func create_pickup(slot_data):
	var _pickup = pickup.instance()
	_pickup.slot_data = slot_data
	get_tree().get_root().add_child(_pickup)
	_pickup.global_transform.origin = Globals.current_player.get_drop_position()

func toggle_inventory_interface(external_inventory_owner = null):
	if current_ui:
		current_ui.visible = !current_ui.visible #toggle current ui
	
	if current_ui.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if external_inventory_owner and current_ui.visible:
		current_ui.set_external_inventory(external_inventory_owner)
	else:
		current_ui.clear_external_inventory()

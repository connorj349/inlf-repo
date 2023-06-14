extends Node

const pickup = preload("res://item/pick_up/Pickup.tscn")
const corpse = preload("res://scenes/Characters/corpse.tscn")

var current_player #allows other objects to reference the player like setting target/etc.
var current_ui #player inventory global reference for other scripts

# warning-ignore:unused_signal
signal on_inventory_toggle
# warning-ignore:unused_signal
signal on_pop_notification

func _ready():
	#begin game with mouse mode captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# warning-ignore:return_value_discarded
	connect("on_inventory_toggle", self, "toggle_inventory_interface")
	#for node in get_tree().get_nodes_in_group("external_inventory"): #currently making each indv storage do this
		#node.connect("toggle_inventory", self, "toggle_inventory_interface")

func create_pickup(slot_data, object = false): #create an item, if object then create at that object's pos instead
	var _pickup = pickup.instance()
	_pickup.slot_data = SlotData.new()
	_pickup.slot_data.item_data = slot_data.item_data
	get_tree().get_root().add_child(_pickup)
	if object:
		_pickup.global_transform.origin = object.global_transform.origin
		return
	_pickup.global_transform.origin = Globals.current_player.get_drop_position()

func create_corpse(object): #create a corpse at object pos
	var _corpse = corpse.instance()
	get_tree().get_root().add_child(_corpse)
	_corpse.global_transform.origin = object.global_transform.origin
	return _corpse #return so that the corpse can be modified by other objects if needed

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

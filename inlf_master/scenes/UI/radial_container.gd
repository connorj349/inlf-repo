extends Container

export var element_radius = 100
export var radiual_width = 50

var inventory_slot = load("res://scenes/UI/inventory_slot.tscn")

#
# THIS ENTIRE SCRIPT IS OUT OF DATE AND WILL NOT BE USED, KEEPING IT FOR DOCUMENTATION'S SAKE
#

func _ready():
	place_elements()
# warning-ignore:return_value_discarded
	Gamestate.connect("on_item_pickup", self, "add_element")
# warning-ignore:return_value_discarded
	Gamestate.connect("on_item_remove", self, "repopulate_radial_menu_icons")

func populate_radial_menu_icons(): #create an icon for each item in player inventory
	for item in Gamestate.player_inventory:
		add_element(item)

func place_elements(): #replaces each element in the container to it's correct position
	var elements = get_children() #all buttons
	if elements.size() == 0: #prevent errors
		return
	var angle_offset = (2*PI)/elements.size()
	var angle = 0
	for element in elements:
		var x = cos(angle) * element_radius
		var y = sin(angle) * element_radius
		var corner_pos = Vector2(x, -y) - (element.get_size() / 2)
		element.set_position(corner_pos)
		angle += angle_offset

func add_element(item_id): #when the player adds a new item to their inventory
	var new_item_slot = inventory_slot.instance()
	new_item_slot.init(item_id)
	add_child(new_item_slot)
	new_item_slot.get_node("Button").connect("pressed", Gamestate, "on_item_used", [item_id])
	place_elements() #reposition elements

func repopulate_radial_menu_icons(): #when the player removes an item from inventory, repopulate everything
	for child in get_children():
		child.queue_free()
	populate_radial_menu_icons()

extends Control

signal drop_slot_data(slot_data)

@onready var player_inventory = $PlayerInventory
@onready var grabbed_slot = $GrabbedSlot
@onready var external_inventory = $ExternalInventory
@onready var equip_inventory = $EquipInventory
@onready var weapon_inventory = $WeaponInventory

var grabbed_slot_data: SlotData = null
var external_inventory_owner

func _ready():
	Globals.current_ui = self
	set_player_inventory_data(Gamestate.player_inventory)
	set_equip_inventory_data(Gamestate.equip_player_inventory)
	set_weapon_inventory_data(Gamestate.weapon_player_inventory)
# warning-ignore:return_value_discarded
	connect("drop_slot_data", Callable(Globals, "create_pickup"))

func _physics_process(_delta): #update the position of the grabbed_slot on the ui
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)

# all three of the below methods can be modified into one, take a inventoryui as arg instead
func set_player_inventory_data(inventory_data: InventoryData): #setup and hookup signals for player inventorydata
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_interact", Callable(self, "on_inventory_interact"))
	#this would be where the invui arg is used
	player_inventory.set_inventory_data(inventory_data)

func set_equip_inventory_data(inventory_data: InventoryData): #setup and hookup signals for player equip inventorydata
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_interact", Callable(self, "on_inventory_interact"))
	equip_inventory.set_inventory_data(inventory_data)

func set_weapon_inventory_data(inventory_data: InventoryData): #setup and hookup signals for player equip inventorydata
# warning-ignore:return_value_discarded
	inventory_data.connect("inventory_interact", Callable(self, "on_inventory_interact"))
	weapon_inventory.set_inventory_data(inventory_data)

func set_external_inventory(_external_inventory_owner): #attaches external inventorydata to the ui
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.connect("inventory_interact", Callable(self, "on_inventory_interact"))
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

func clear_external_inventory(): #removes reference to external inventorydata
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.disconnect("inventory_interact", Callable(self, "on_inventory_interact"))
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null

func on_inventory_interact(inventory_data, index, button): #when any inventory ui is interacted with
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]: #currently no slot data grabbed and left clicking
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]: #anything(wildcard) info, and left click
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]: #case for using item
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]: #dropping item
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()

func update_grabbed_slot(): #update the grabbed slot ui element
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func _on_InventoryInterface_gui_input(event):
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				emit_signal("drop_slot_data", grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				emit_signal("drop_slot_data", grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()

func _on_InventoryInterface_visibility_changed():
	if not visible and grabbed_slot_data:
		emit_signal("drop_slot_data", grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()

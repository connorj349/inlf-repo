extends Interactable

@export var input_item_datas: Array[ItemData] #input item # (Array, Resource)
@export var output_item_datas: Array[ItemData] #output item # (Array, Resource)
@export var machine_name: String = "NULL"
@export var production_time: float = 3.0 # time it takes to make item
@export var payday: int = 0 # how much the player is paid out, maybe make this a constant in globals
@export var required_role = Role.Role_Type.Worker # (Role.Role_Type)

@onready var timer = $ManufactureTimer

# UI Elements
@onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
@onready var name_plate = $CanvasLayer/Info/VBoxContainer/NameLabel
@onready var materials_label = $CanvasLayer/Info/VBoxContainer/MaterialsLabel
@onready var panel = $CanvasLayer/PanelContainer
@onready var next_action_label = $CanvasLayer/PanelContainer/VBoxContainer/Label

# Sounds
@onready var accept_input = $AcceptSound
@onready var machine_loop = $MachineLoop

var rng = RandomNumberGenerator.new()

var current_index : set = set_current_index
var button_presses_remaining = 5
var queued_items = 0
var materials = 0: set = set_materials

func _ready():
	self.current_index = 0
	timer.wait_time = production_time # setup timer limit
	name_plate.text = machine_name # setup nameplate
	prog_bar.init(0, production_time) # init progress bar
	rng.randomize()
# warning-ignore:return_value_discarded
	Globals.connect("on_inventory_toggle", Callable(panel, "hide"))
	if !is_in_group("machine"):
		add_to_group("machine")

func _process(_delta): #update the manufacture progress bar onscreen
	if timer.time_left > 0:
		prog_bar.update_bar(timer.time_left)

func _interact(actor):
	if can_interact:
		if actor.role.role_type == required_role:
			panel.show()
			if panel.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			Globals.emit_signal("on_pop_notification", "I don't know how to use this machine.")

func button_press(index):
	if !can_interact:
		panel.hide()
		return
	if materials > 0:
		if index == current_index:
			button_presses_remaining -= 1
			self.materials -= 1
			Gamestate.bones += payday
			self.current_index = rng.randi_range(0, 2)
			if button_presses_remaining <= 0:
				button_presses_remaining = 5
				Gamestate.bones += payday * 2
				queued_items += 1
				timer.start()
				machine_loop.play()
		else:
			pass
			#Globals.current_player.hurt(damage)

func set_current_index(value):
	match(value):
		0:
			next_action_label.text = "ASSEMBLE"
		1:
			next_action_label.text = "ALIGN"
		2:
			next_action_label.text = "CAUTERIZE"
	current_index = clamp(value, 0, 2)

func set_materials(value):
	materials = clamp(value, 0, 999)
	materials_label.text = "Material: " + str(materials)

func _on_ManufactureTimer_timeout():
	queued_items -= 1
	var random_index = rng.randi_range(0, output_item_datas.size() - 1)
	var new_slot = SlotData.new()
	new_slot.item_data = output_item_datas[random_index]
	Gamestate.merchant_inventory.add_item(new_slot)
	if queued_items > 0:
		timer.start()
	else:
		timer.stop()
		machine_loop.stop()

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		for item in input_item_datas:
			if body.slot_data.item_data == item:
				for i in body.slot_data.quantity:
					Gamestate.bones += payday
					self.materials += 1
				accept_input.play()
				body.queue_free()
				return

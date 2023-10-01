extends Interactable

export(Resource) var input_item_slot #input item
export(Array, Resource) var out_item_slots #output item
export(String) var machine_name = "NULL"
export(float) var production_time = 3.0 # time it takes to make item
export(int) var payday = 0 # how much the player is paid out
export(Role.Role_Type) var required_role = Role.Role_Type.OTHER

onready var timer = $ManufactureTimer
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label
onready var accept_input = $AcceptSound
onready var machine_loop = $MachineLoop

var rng = RandomNumberGenerator.new()

func _ready():
	timer.wait_time = production_time # setup timer limit
	name_plate.text = machine_name # setup nameplate
	prog_bar.init(0, production_time) # init progress bar
	rng.randomize()

func _process(_delta): #update the manufacture progress bar onscreen
	if timer.time_left > 0:
		prog_bar.update_bar(timer.time_left)

func _interact(_actor):
	if _actor.role.role_type == required_role: # only enable interacting if correct role UPDATE TO ROLE_WORKER
		if can_interact:
			if Gamestate.player_inventory.take_item(input_item_slot): #take item and count needed from player
				Gamestate.bones_updated(payday)
				accept_input.play()
				can_interact = false
				timer.start()
				machine_loop.play()
	else:
		Globals.emit_signal("on_pop_notification", "I don't know how to use this machine.")

func _on_ManufactureTimer_timeout():
	var random_index = rng.randi_range(0, out_item_slots.size() - 1)
	can_interact = true # enable interaction
	timer.stop()
	machine_loop.stop()
	Gamestate.merchant_inventory.pick_up_slot_data(out_item_slots[random_index])

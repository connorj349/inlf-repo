extends Interactable

#update this so we can just have a single machine that is changed at runtime by altering variables

export(Resource) var input_item_id #input item
export(Resource) var output_item_id #output item
export(String) var machine_name = "NULL"
export(float) var production_time = 3 #time it takes to make item

onready var timer = $ManufactureTimer
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label
onready var accept_input = $AcceptSound
onready var machine_loop = $MachineLoop

func _ready():
	timer.wait_time = production_time #setup timer limit
	name_plate.text = machine_name #setup nameplate
	prog_bar.init(0, production_time)

func _process(_delta): #update the manufacture progress bar onscreen
	if timer.time_left > 0:
		prog_bar.update_bar(timer.time_left)

func _interact(_actor):
	if can_interact:
		if Gamestate.player_inventory.take_item(input_item_id): #take item and count needed from player
			accept_input.play()
			can_interact = false
			timer.start()
			machine_loop.play()

func _on_ManufactureTimer_timeout():
	can_interact = true #enable interaction
	timer.stop()
	machine_loop.stop()
	Gamestate.merchant_inventory.add_item(output_item_id)

extends Interactable

#update this so we can just have a single machine that is changed at runtime by altering variables

export(Resource) var input_item_id #input item
export(Resource) var output_item_id #output item
export(String) var machine_name = "NULL"
export(float) var production_time = 3 #time it takes to make item

onready var anim_player = $AnimationPlayer
onready var timer = $ManufactureTimer
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label

func _ready():
	timer.wait_time = production_time #setup timer limit
	name_plate.text = machine_name #setup nameplate
	prog_bar.init(0, production_time)

func _process(_delta): #update the manufacture progress bar onscreen
	if timer.time_left > 0:
		prog_bar.update_bar(timer.time_left)

func _interact(_actor):
	if can_interact:
		if Gamestate.player_inventory.take_item(input_item_id): #take item needed from player
			can_interact = false
			timer.start()
			#play machine loop sound

func _on_ManufactureTimer_timeout():
	can_interact = true #enable interaction
	timer.stop()
	Gamestate.merchant_inventory.add_item(output_item_id)
	#stop machine loop sound

func _display_info(): #override, can even add sounds to this as it's not played dozens of times
	anim_player.play("fade_in")

func _hide_info(): #play animation in reverse
	anim_player.play_backwards("fade_in")

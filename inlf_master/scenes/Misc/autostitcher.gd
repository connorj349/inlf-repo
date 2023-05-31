extends Interactable

# add an animation to the stitchers on the machine
# add a stitching sound when the player is being healed

export(int) var heal_cost = 50 #how many bones to heal
export(int) var heal_amount = 5 #amount to heal player

onready var anim_player = $AnimationPlayer
onready var heal_area = $Area
onready var timer = $Timer
onready var charges_nameplate = $CanvasLayer/Info/VBoxContainer/Charges

var charges = 3 #start with three

func _ready():
	heal_area.connect("body_exited", self, "stop_healing") #stop the healing process if anything leaves area
	change_charge_count(0) #setup text

func on_hurt(_amount): #when damaged, has a chance to give a charge, if caught will be attacked
	change_charge_count(1) # debug, just give a charge for now, will change to random

func _interact(_actor):
	if can_interact:
		if charges > 0:
			can_interact = false
			change_charge_count(-1) #remove a charge
			timer.start() #start timer

func stop_healing(_body):
	can_interact = true
	timer.stop()

func change_charge_count(amount): # negative amounts are subtraction, positive are adding
	charges = clamp(charges + amount, 0, 3)
	charges_nameplate.text = "charges: " + str(charges)

func _on_Timer_timeout(): # this technically heals ALL bodies within the vicinity
	for body in heal_area.get_overlapping_bodies():
		if body.has_method("on_heal") and body != self:
			body.on_heal(heal_amount)

func _display_info():
	anim_player.play("fade_in")

func _hide_info():
	anim_player.play_backwards("fade_in")

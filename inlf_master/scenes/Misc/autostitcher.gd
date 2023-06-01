extends Interactable

# add an animation to the stitchers on the machine
# add a stitching sound when the player is being healed

export(int) var heal_cost = 50 #how many bones to heal
export(int) var heal_amount = 5 #amount to heal player

onready var heal_area = $Area
onready var timer = $Timer
onready var charges_nameplate = $CanvasLayer/Info/VBoxContainer/Charges

var charges = 3 #start with three

func _ready():
	heal_area.connect("body_exited", self, "stop_healing") #stop the healing process if anything leaves area
	change_charge_count(0) #setup text
	randomize()

func on_hurt(_amount): #when damaged, has a chance to give a charge, if caught will be attacked by sanitars
	#play a hit sound
	var random_hit_result = randf()
	if random_hit_result < 0.8:
		# 80% chance of being returned
		pass
	elif random_hit_result < 0.95:
		# 15% chance of being returned
		change_charge_count(1) # add charge
	else:
		# 5% chance of being returned
		change_charge_count(1) # add charge and automatically begin healing cycle
		start_healing(true) # override and not consume any charges and immediately begin healing

func _interact(_actor):
	if can_interact:
		start_healing()

func start_healing(override = false):
	if override:
		can_interact = false
		timer.start()
		return
		
	if charges > 0:
		can_interact = false
		change_charge_count(-1)
		timer.start()

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

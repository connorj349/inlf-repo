extends Interactable

# purely cosmetic changes that need to be applied
# add an animation to the stitchers on the machine
# add blood particles that spawn randomly as the machine is running

#export(int) var heal_cost = 50 #how many bones to heal
export(int) var heal_amount = 5 #amount to heal player per tick

onready var heal_area = $Area
onready var timer = $Timer
onready var charges_nameplate = $CanvasLayer/Info/VBoxContainer/Charges
onready var healing_loop = $HealingLoop
onready var hit_sound = $HitSound

var charges = 3 #start with three

func _ready():
	heal_area.connect("body_exited", self, "stop_healing") #stop the healing process if anything leaves area
	change_charge_count(0) #setup ui text
	randomize()

func on_hurt(_amount): #when damaged, has a chance to give a charge, if caught will be attacked by sanitars
	hit_sound.play()
	#spawn spark particle effect
	var random_hit_result = randf()
	if random_hit_result < 0.8:
		# 80% chance of being returned; nothing happens
		pass
	elif random_hit_result < 0.95:
		# 15% chance of being returned
		change_charge_count(1) # add charge
	else:
		# 5% chance of being returned
		start_healing(false) # not consume any charges and begin healing

func _interact(_actor):
	if can_interact and charges > 0:
		start_healing()

func start_healing(consume_charges = true):
	if timer.is_stopped():
		healing_loop.play(0) #start the healing loop at the beginning
		can_interact = false
		timer.start()
		if consume_charges:
			change_charge_count(-1)

func stop_healing(_body):
	can_interact = true
	timer.stop()
	healing_loop.stop()

func change_charge_count(amount): # negative amounts are subtraction, positive are adding
	charges = clamp(charges + amount, 0, 3)
	charges_nameplate.text = "charges: " + str(charges)

func _on_Timer_timeout(): # this technically heals ALL bodies within the vicinity
	# spawn blood splatter particle effects
	for body in heal_area.get_overlapping_bodies():
		if body.has_method("on_heal") and body != self:
			body.on_heal(heal_amount)

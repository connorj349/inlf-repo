extends Interactable

# add an animation to the stitchers on the machine

export(int) var heal_cost = 25 #how many bones to heal
export(int) var heal_amount = 5 #amount to heal player per tick

onready var heal_area = $Area
onready var timer = $Timer
onready var healing_loop = $HealingLoop
onready var hit_sound = $HitSound

var blood_effect = preload("res://effects/blood_spray.tscn")

func _ready():
	heal_area.connect("body_exited", self, "stop_healing") #stop the healing process if anything leaves area
	randomize()

func on_hurt(_amount): #if caught will be attacked by sanitars
	hit_sound.play()
	#spawn spark particle effect
	var random_hit_result = randf()
	if random_hit_result < 0.8:
		# 80% chance of being returned; nothing happens
		pass
	elif random_hit_result < 0.95:
		# 15% chance of being returned
		start_healing()
	else:
		# 5% chance of being returned
		pass

func _interact(_actor):
	if can_interact and Gamestate.can_afford(heal_cost):
		start_healing()
		Gamestate.bones_updated(-heal_cost)

func start_healing():
	if timer.is_stopped():
		healing_loop.play(0) #start the healing loop at the beginning
		can_interact = false
		timer.start()

func stop_healing(_body):
	can_interact = true
	timer.stop()
	healing_loop.stop()

func _on_Timer_timeout(): # this technically heals ALL bodies within the vicinity
	for body in heal_area.get_overlapping_bodies():
		if body.has_method("on_heal") and body != self:
			body.on_heal(heal_amount)
			var heal_effect = blood_effect.instance()
			get_tree().get_root().add_child(heal_effect)
			heal_effect.global_transform.origin = body.global_transform.origin

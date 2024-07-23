extends Interactable

@export var heal_cost: int = 50 # how many bones to heal
@export var heal_amount: int = 1 # amount to heal player per tick
@export var blood_effect: PackedScene

@onready var heal_area = $Area3D
@onready var timer = $Timer
@onready var healing_loop = $HealingLoop
@onready var hit_sound = $SoundQueue3D

func _ready():
	heal_area.connect("body_exited", Callable(self, "stop_healing")) #stop the healing process if anything leaves area
	randomize()

func on_hurt(_amount): # if caught will be attacked by sanitars
	hit_sound.PlaySoundRange(0.9, 1.1)
	# spawn spark particle effect
	var random_hit_result = randf()
	if random_hit_result < 0.8:
		# 80% chance of being returned; nothing happens
		# maybe make this 'want' the player automatically by the sanitar squad
		pass
	elif random_hit_result < 0.95:
		# 15% chance of being returned
		start_healing()
	else:
		# 5% chance of being returned
		pass

func _interact(_actor):
	if can_interact and Gamestate.bones >= heal_cost:
		start_healing()
		Gamestate.bones -= heal_cost
	else:
		if Gamestate.bones >= heal_cost:
			Gamestate.bones -= heal_cost
			Globals.current_player.health.pox = 0

func start_healing():
	if timer.is_stopped():
		$mdl_autostitcher/AnimationPlayer.play("active")
		healing_loop.play(0) #start the healing loop at the beginning
		can_interact = false
		timer.start()

func stop_healing(_body):
	$mdl_autostitcher/AnimationPlayer.play("idle", 1)
	can_interact = true
	timer.stop()
	healing_loop.stop()

func _on_Timer_timeout(): # this technically heals ALL bodies within the vicinity
	for body in heal_area.get_overlapping_bodies():
		if body.has_method("on_heal") and body != self:
			body.on_heal(heal_amount)
			var heal_effect = blood_effect.instantiate()
			get_tree().get_root().add_child(heal_effect)
			heal_effect.global_transform.origin = body.global_transform.origin

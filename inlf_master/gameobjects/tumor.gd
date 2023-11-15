extends HintObject

#export(Resource) var slot_data # cancer item to spawn for player
#export(int) var number_of_roaches_to_spawn = 3
export(int) var rot_increase_amount = 1
export(int) var rot_inrease_frequency = 1

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var hurt_area = $HurtArea

func _ready():
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	$RotTimer.wait_time = rot_inrease_frequency #set frequency by which rot is increased
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_hurt(amount):
	if !health.death_sound.is_playing():
		health.hurt(amount)
		# spawn a Rotroach(s) that immediately attack the player

func on_death():
	# spawn tumor bloody pop effect
	# spawn rotroach hive(this hive spawns 3 roaches, then dissapears)
	yield(health.death_sound, "finished")
	#Globals.create_pickup(slot_data, self)
	queue_free() # delete this object

func _on_RotTimer_timeout():
	Gamestate.rot_modify(rot_increase_amount) # make global const var

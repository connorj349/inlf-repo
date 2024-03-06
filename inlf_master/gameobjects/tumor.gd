extends HintObject

#export(Resource) var slot_data # cancer item to spawn for player
#export(int) var number_of_roaches_to_spawn = 3
export(int) var rot_increase_amount = 1
export(int) var rot_inrease_frequency = 1

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var hurt_area = $HurtArea

var dead = false
var tumor_damage = Damage.new()

func _ready():
	tumor_damage.amount = 5
	randomize()
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	$RotTimer.wait_time = rot_inrease_frequency #set frequency by which rot is increased
	anim_player.play("RESET")
	anim_player.seek(0, true)
	Gamestate.tumors += 1

func on_hurt(damage):
	if dead:
		return
	match(damage):
		Damage.DamageType.Fists:
			Globals.current_player.on_hurt(tumor_damage) # damage the player back when struck
			var random_result = randf()
			if random_result < .5:
				health.hurt(damage.amount) # takes damage half the time from fists
		_:
			health.hurt(damage.amount) # takes damage in all cases
	# spawn a Rotroach(s) that immediately attack the player

func on_death():
	Gamestate.tumors -= 1
	dead = true
	# spawn tumor bloody pop effect
	# spawn rotroach hive(this hive spawns 3 roaches, then dissapears)
	yield(health.death_sound, "finished")
	#Globals.create_pickup(slot_data, self)
	queue_free() # delete this object

func _on_RotTimer_timeout():
	Gamestate.rot_modify(rot_increase_amount) # make global const var

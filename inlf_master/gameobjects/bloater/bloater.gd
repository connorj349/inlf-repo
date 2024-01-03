extends HintObject

# drop an item on death
# add looping 'gestation' sounds to clue player to this items' location
# clean up UI

export(int) var incubation_increase_amount = 5
export(float) var incubation_frequency_amount = 1.0

onready var health = $Health
onready var hp_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var incu_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar2
onready var timer = $Timer

var incubation = 0

var dead = false

func _ready():
	health.init()
	health.connect("health_changed", hp_bar, "update_bar")
	health.connect("dead", self, "on_death")
	hp_bar.init(health.health, health.max_health)
	incu_bar.init(0, 100)
	timer.wait_time = incubation_frequency_amount
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_hurt(damage):
	if dead:
		return
	health.hurt(damage.amount) # just take damage, no additional calculations required

func on_death():
	dead = true
	anim_player.play("pop")
	yield(health.death_sound, "finished") #wait until the death sound is finished
	yield(anim_player, "animation_finished")
	#drop random cancer item
	queue_free()

func _on_Timer_timeout():
	incubation = clamp(incubation + incubation_increase_amount, 0, 100)
	incu_bar.update_bar(incubation)
	if incubation == 100:
		Gamestate.rot_modify(5) #increaes rot
		on_death()
		timer.stop() # prevents rot from being modified more than once before death

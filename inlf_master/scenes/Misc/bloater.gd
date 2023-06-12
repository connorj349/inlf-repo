extends HintObject

# drop an item on death
# add death sound
# add looping 'gestation' sounds to clue player to this items' location
# clean up UI
# create init method so this can be spawned by infestations

export(int) var incubation_increase_amount = 5
export(float) var incubation_frequency_amount = 1.0

onready var health = $Health
onready var hp_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var incu_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar2
onready var timer = $Timer

var incubation = 0

func _ready():
	health.init()
	health.connect("health_changed", hp_bar, "update_bar")
	health.connect("dead", self, "on_death")
	hp_bar.init(health.health, health.max_health)
	incu_bar.init(0, 100)
	timer.wait_time = incubation_frequency_amount
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_hurt(amount):
	if !health.death_sound.is_playing():
		health.hurt(amount)

func on_death():
	yield(health.death_sound, "finished") #wait until the death sound is finished
	#drop random cancer item
	queue_free()

func _on_Timer_timeout():
	incubation = clamp(incubation + incubation_increase_amount, 0, 100)
	incu_bar.update_bar(incubation)
	if incubation >= 100:
		Gamestate.rot_modify(25) #increaes rot
		on_hurt(999)

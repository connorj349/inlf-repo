extends Interactable

#must be role resource
export(Resource) var harvest_role # could be an array in future, for cultist/korpsman/misfit
# needs to be slot data
export(Resource) var common_organ
export(Resource) var uncommon_organ
export(Resource) var rare_organ

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var organ_spawn = $organ_spawnpoint

onready var big_flesh = $flesh_large
var blood_spray = preload("res://effects/blood_spray.tscn")

func _ready():
	randomize()
	# spawn gib effects and blood effects to simulate corpse explosion after death
	health.init()
	health.connect("health_changed", prog_bar, "update_bar")
	health.connect("dead", self, "destroy")
	#maybe make a death blood explosion? this could be useful for the interact that will just call on_death
	prog_bar.init(health.health, health.max_health)
	state_text.text = "Fresh"
	spawn_blood()

func on_hurt(amount): #damages corpse
	health.hurt(amount)

func _interact(_actor): # what does this do to actually help the non-cultist player?
	if can_interact:
		if _actor.role == harvest_role:
			spawn_organ()
			big_flesh.visible = false
		else:
			_actor.on_heal(25)
			big_flesh.visible = false
		spawn_blood()
		on_hurt(75)
		can_interact = false

func spawn_blood():
	var blood = blood_spray.instance()
	add_child(blood)
	blood.global_transform.origin = self.global_transform.origin

func _on_DecayTimer_timeout(): #updates corpse state text on UI
	on_hurt(1)
	Gamestate.rot_modify(1)
	if health.health > 75:
		state_text.text = "Fresh"
	elif health.health < 75 and health.health > 25:
		state_text.text = "Rotting"
	elif health.health < 25:
		state_text.text = "Husk"

func destroy():
	queue_free() # remove this object

func spawn_organ():
	var random_result = randf()
	if random_result < 0.8:
		Globals.create_pickup(common_organ, organ_spawn)
	elif random_result < 0.95:
		Globals.create_pickup(uncommon_organ, organ_spawn)
	else:
		Globals.create_pickup(rare_organ, organ_spawn)

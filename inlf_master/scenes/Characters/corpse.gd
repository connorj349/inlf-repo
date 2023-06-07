extends Interactable # maybe corpse could be a storage, holding organs/flesh inside instead of other items

#must be role resource
export(Resource) var harvest_role # could be an array in future, for cultist/korpsman/misfit
# needs to be slot data
export(Resource) var common_organ
export(Resource) var uncommon_organ
export(Resource) var rare_organ

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var movement = $Movement

func _ready():
	randomize()
	# spawn gib effects and blood effects to simulate corpse explosion after death
	movement.init(self)
	health.init()
	health.connect("health_changed", prog_bar, "update_bar")
	#maybe make a death blood explosion? this could be useful for the interact that will just call on_death
	prog_bar.init(health.health, health.max_health)
	state_text.text = "Fresh"

func on_hurt(amount): #damages corpse
	health.hurt(amount)

func _interact(_actor): # what does this do to actually help the non-cultist player?
	if _actor.role == harvest_role:
		spawn_organ()
		destroy()
	else:
		_actor.on_heal(25)
		destroy()

func _on_DecayTimer_timeout(): #updates corpse state text on UI
	on_hurt(1)
	Gamestate.rot_modify(1)
	if health.health > 75:
		state_text.text = "Fresh"
	elif health.health < 75 and health.health > 25:
		state_text.text = "Rotting"
	elif health.health < 25:
		state_text.text = "Husk"
	else:
		destroy()

func destroy():
	# play destroy corpse effect(blood splatters/gibs
	queue_free() # remove this object

func spawn_organ():
	var random_result = randf()
	if random_result < 0.8:
		Globals.create_pickup(common_organ, self)
	elif random_result < 0.95:
		Globals.create_pickup(uncommon_organ, self)
	else:
		Globals.create_pickup(rare_organ, self)

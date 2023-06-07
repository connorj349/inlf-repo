extends Interactable # maybe corpse could be a storage, holding organs/flesh inside instead of other items

# want to make this so that anyone dying spawns a corpse, maybe use Globals/Gamestate to spawn corpses just like
# items are spawned?
# ADD the ability to cannibalize
# ADD the ability to harvest organs for cultists' rituals

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var movement = $Movement

func _ready():
	# spawn gib effects and blood effects to simulate corpse explosion after death
	movement.init(self)
	health.init()
	health.connect("health_changed", prog_bar, "update_bar")
	#maybe make a death blood explosion? this could be useful for the interact that will just call on_death
	prog_bar.init(health.health, health.max_health)
	state_text.text = "Fresh"

func on_hurt(amount): #damages corpse
	health.hurt(amount)
	#drops organ

func _interact(_actor): # what does this do to actually help the non-cultist player?
	queue_free()
	#eats corpse
	#if cultist, harvest organs instead?(do we want cultists to lose this ability)

func _on_DecayTimer_timeout(): #updates corpse state text on UI
	on_hurt(1)
	Gamestate.rot_modify(1)
	if health.health > 75:
		state_text.text = "Fresh"
	elif health.health < 75 and health.health > 25:
		state_text.text = "Rotting"
	elif health.health <= 0:
		state_text.text = "Husk"
		queue_free() #remove husk for early dev purposes

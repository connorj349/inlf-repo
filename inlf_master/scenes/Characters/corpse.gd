extends Interactable

# want to make this so that anyone dying spawns a corpse, maybe use Globals/Gamestate to spawn corpses just like
# items are spawned?
# ADD the ability to cannibalize
# ADD the ability to harvest organs for cultists' rituals

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var state_text = $CanvasLayer/Info/VBoxContainer/ProgressBar/Label
onready var movement = $Movement

func _ready():
	movement.init(self)
	health.init()
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	state_text.text = "Fresh"

func on_hurt(amount): #damages corpse
	health.hurt(amount)

func _interact(_actor): #just removes the corpse for now
	queue_free()

func _on_DecayTimer_timeout(): #updates corpse state text on UI
	on_hurt(1)
	Gamestate.rot_modify(1)
	if health.health > 75:
		state_text.text = "Fresh"
	elif health.health < 75 and health.health > 25:
		state_text.text = "Rotted"
	elif health.health <= 0:
		state_text.text = "Husk"
		queue_free() #remove husk for early dev purposes

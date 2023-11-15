extends Interactable

export(Resource) var slot_data #resource item to drop on death
export(String) var display_name = "NULL" #what to display on nameplate

onready var health = $Health
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar

var item_prefab = preload("res://item/pick_up/Pickup.tscn")

func _ready():
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	name_plate.text = display_name
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_death(): #spawn item, delete self
	# play the break effect
	# turn model visible = false
	yield(health.death_sound, "finished") #wait until the death sound is finished
	Globals.create_pickup(slot_data, self)
	queue_free() #destroy

func on_hurt(amount):
	if !health.death_sound.is_playing():
		health.hurt(amount)

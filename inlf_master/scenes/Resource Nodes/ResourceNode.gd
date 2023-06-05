extends Interactable

# change so that instead of 4 different Resource nodes for each resource we instead
# have a single resource node that can be customized at runtime

# vars needed
# slot_data
# display_name
# max_health
# model

export(Resource) var slot_data #resource item to drop on death
export(String) var display_name = "NULL" #what to display on nameplate

onready var health = $Health
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Label
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar

var item_prefab = preload("res://item/pick_up/Pickup.tscn")

#func init(_slot_data: Resource, _name: String, _max_health, model: PackedScene):
	#slot_data = _slot_data
	#name_plate.text = _name
	#health.max_health = _max_health
	#health.init() #setup health
	#prog_bar.init(health.health, health.max_health)

func _ready():
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	name_plate.text = display_name
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_death(): #spawn item, delete self
	yield(health.death_sound, "finished") #wait until the death sound is finished
	Globals.create_pickup(slot_data, self)
	queue_free() #destroy

func on_hurt(amount):
	if !health.death_sound.is_playing():
		health.hurt(amount)

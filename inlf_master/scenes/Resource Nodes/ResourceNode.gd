extends Interactable

# change so that instead of 4 different Resource nodes for each resource we instead
# have a single resource node that can be customized at runtime

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
	var spawned_item = item_prefab.instance()
	spawned_item.slot_data = slot_data
	spawned_item.global_transform = global_transform
	get_tree().get_root().add_child(spawned_item)
	#death_sound.play() #play death sound
	#if !death_sound.is_playing(): #when done playing, destroy
	queue_free() #dont forget to indent when adding sounds playing

func on_hurt(amount):
	health.hurt(amount)

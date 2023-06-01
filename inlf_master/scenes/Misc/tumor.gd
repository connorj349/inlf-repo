extends HintObject

# add death sounds
# change Globals.create_item so that it accepts an object to spawn the item at so we can get rid
# of the spawning that is done in this object

export(Resource) var slot_data #cancer item to spawn for player
export(int) var damage = 10
export(int) var rot_increase_amount = 1
export(int) var rot_inrease_frequency = 1

onready var health = $Health
onready var prog_bar = $CanvasLayer/Info/VBoxContainer/ProgressBar
onready var hurt_area = $HurtArea

var item_prefab = preload("res://item/pick_up/Pickup.tscn")

func _ready():
	health.init()
	health.connect("dead", self, "on_death")
	health.connect("health_changed", prog_bar, "update_bar")
	prog_bar.init(health.health, health.max_health)
	$RotTimer.wait_time = rot_inrease_frequency #set frequency by which rot is increased
	anim_player.play("RESET")
	anim_player.seek(0, true)

func on_hurt(amount):
	health.hurt(amount)
	if hurt_area.monitoring:
		for body in hurt_area.get_overlapping_bodies():
			if body.has_method("on_hurt") and body != self:
				body.on_hurt(damage) #deal damage to all things around tumor when it's hurt

func on_death():
	var spawned_item = item_prefab.instance()
	spawned_item.global_transform = global_transform
	spawned_item.slot_data = slot_data
	get_tree().get_root().add_child(spawned_item)
	#death_sound.play() #play death sound
	#if !death_sound.is_playing(): #when done playing, destroy
	queue_free()

func _on_RotTimer_timeout():
	Gamestate.rot_modify(rot_increase_amount)

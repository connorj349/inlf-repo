extends HintObject

signal increase_rot(amount: int)

@export var cancer_item_data: ItemData # cancer item to spawn for player
@export var rot_increase_amount: int = 1
@export var rot_inrease_frequency: int = 5
@export var prog_bar: ProgressBar
@export var tumor_damage: Damage

var dead = false

@onready var health = $Health
@onready var hit_sound: AudioStreamPlayer3D = $HitSound
@onready var ambient_sound: AudioStreamPlayer3D = $AmbientSound

func _ready():
	if !is_in_group("rot_producers"):
		add_to_group("rot_producers")
	
	randomize()
	health.init()
	health.connect("dead", Callable(self, "on_death"))
	health.connect("health_changed", Callable(prog_bar, "update_bar"))
	prog_bar.init(health.health, health.max_health)
	$RotTimer.wait_time = rot_inrease_frequency #set frequency by which rot is increased
	get_tree().current_scene.game_world.current_level.tumors += 1
	ambient_sound.play()

func on_hurt(damage):
	if dead:
		return
	match(damage):
		Damage.DamageType.Fists:
			damage.source.on_hurt(tumor_damage) # damage the player back when struck
			var random_result = randf()
			if random_result < .5:
				health.health -= damage.amount # takes damage half the time from fists
		_:
			health.health -= damage.amount # takes damage in all cases
			ambient_sound.play()

func on_death():
	get_tree().current_scene.game_world.current_level.tumors -= 1
	dead = true
	# spawn tumor bloody pop effect
	var new_item = SlotData.new()
	new_item.item_data = cancer_item_data
	
	var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
	new_pickup.slot_data = new_item
	get_tree().current_scene.game_world.add_child(new_pickup)
	new_pickup.global_transform.origin = $ItemSpawnPosition.global_transform.origin
	
	queue_free()

func _on_RotTimer_timeout():
	increase_rot.emit(rot_increase_amount)

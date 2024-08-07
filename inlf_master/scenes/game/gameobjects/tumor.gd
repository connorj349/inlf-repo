extends HintObject

@export var cancer_item_data: ItemData # cancer item to spawn for player
#export(int) var number_of_roaches_to_spawn = 3
@export var rot_increase_amount: int = 1
@export var rot_inrease_frequency: int = 5
@export var prog_bar: ProgressBar
@export var tumor_damage: Damage

var dead = false

@onready var health = $Health

func _ready():
	randomize()
	health.init()
	health.connect("dead", Callable(self, "on_death"))
	health.connect("health_changed", Callable(prog_bar, "update_bar"))
	prog_bar.init(health.health, health.max_health)
	$RotTimer.wait_time = rot_inrease_frequency #set frequency by which rot is increased
	Gamestate.tumors += 1

func on_hurt(damage):
	if dead:
		return
	match(damage):
		Damage.DamageType.Fists:
			Globals.current_player.on_hurt(tumor_damage) # damage the player back when struck
			var random_result = randf()
			if random_result < .5:
				health.health -= damage.amount # takes damage half the time from fists
		_:
			health.health -= damage.amount # takes damage in all cases
	# spawn a Rotroach(s) that immediately attack the player

func on_death():
	Gamestate.tumors -= 1
	dead = true
	# spawn tumor bloody pop effect
	# spawn rotroach hive(this hive spawns 3 roaches, then dissapears)
	var new_item = SlotData.new()
	new_item.item_data = cancer_item_data
	Globals.create_pickup(new_item, $ItemSpawnPosition)
	queue_free() # delete this object

func _on_RotTimer_timeout():
	Gamestate.rot += rot_increase_amount

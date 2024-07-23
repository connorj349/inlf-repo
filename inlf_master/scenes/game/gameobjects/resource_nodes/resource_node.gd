extends Interactable

@export var item_data: Resource #resource item to drop on death
@export var blocked_damage_types: Array[Damage.DamageType] # (Array, Damage.DamageType)
@export var punching_hurts: bool = false
@export var optional_item_spawn_point: NodePath
@export var hit_effect: PackedScene
@export var item_prefab: PackedScene
@export var prog_bar: ProgressBar

var dead = false

@onready var health = $Health

func _ready():
	health.init()
	health.connect("dead", Callable(self, "on_death"))
	health.connect("health_changed", Callable(prog_bar, "update_bar"))
	prog_bar.init(health.health, health.max_health)
	anim_player.play("RESET")
	anim_player.seek(0, true)
	randomize()

func on_death(): #spawn item, delete self
	dead = true
	var new_item = SlotData.new()
	new_item.item_data = item_data
	if optional_item_spawn_point:
		Globals.create_pickup(new_item, get_node(optional_item_spawn_point))
	else:
		Globals.create_pickup(new_item, self)
	queue_free() #destroy

func on_hurt(damage):
	if dead:
		return
	
	var new_effect = hit_effect.instantiate()
	get_tree().get_root().add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	
	var random_result = randf()
	for damage_type in blocked_damage_types:
		if damage.type == Damage.DamageType.Fists:
			if punching_hurts:
				var player_hurt_damage = Damage.new()
				player_hurt_damage.amount = 1
				Globals.current_player.on_hurt(player_hurt_damage) #replace with damage from this object
			health.health -= damage.amount #always damage the resource_node with fists, but hurt player
			return
		elif damage.type == damage_type:
			if random_result < 0.5: #fifty percent chance to deal damage to object
				health.health -= damage.amount
				return
		else:
			health.health -= damage.amount #deal damage to object

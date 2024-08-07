extends CharacterBody3D

enum STATE { IDLE, PATROL, ATTACK }

@export var inventory_data: Resource
@export var loot_table: Array[ItemData]
@export var will_retaliate: bool = false

var current_state = STATE.IDLE
var target = null

@onready var health = $Health
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	randomize()
	health.init()
	health.connect("dead", Callable(self, "kill"))
	randomize_loot()
	
	# prevents error on startup from processing finding new paths in physics_process
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)
	
	call_deferred("setup_actor")

func _process(delta):
	match(current_state):
		STATE.IDLE:
			process_idle_state(delta)
		STATE.PATROL:
			process_patrol_state(delta)
		STATE.ATTACK:
			process_attack_state(delta)

func _physics_process(_delta):
	if navigation_agent.is_navigation_finished():
		$korpsman/AnimationPlayer.play("Idle")
		await get_tree().create_timer(2.0).timeout
		setup_actor()
		return
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * 2.0
	
	_safe_look_at(self, next_path_position)
	rotate_object_local(Vector3.UP, PI)
	
	move_and_slide()

func setup_actor():
	await get_tree().physics_frame
	
	var random_target_position = global_position + Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
	
	# turn towards target location using delta
	# once within a specific angle of target location, allow movement
	# this should prevent constantly looking for a new position and moving
	
	if (global_transform.origin - random_target_position).length() < 1:
		print("target too close")
	
	set_target_movement(random_target_position)

func set_target_movement(movement_target: Vector3):
	navigation_agent.set_target_position(_get_point_on_map(movement_target, 0.5))
	$korpsman/AnimationPlayer.play("Run")

# checks if a certain point is on the navigation map, returns a point
func _get_point_on_map(target_point: Vector3, min_distance_from_edge: float):
	var map := get_world_3d().navigation_map
	var closest_point := NavigationServer3D.map_get_closest_point(map, target_point)
	var delta := closest_point - target_point
	var is_on_map = delta.is_zero_approx()
	if not is_on_map and min_distance_from_edge > 0:
		delta = delta.normalized()
		closest_point += delta * min_distance_from_edge
	return closest_point

func _safe_look_at(_node: Node3D, _target: Vector3):
	var origin: Vector3 = _node.global_transform.origin
	var v_z := (origin - _target).normalized()
	
	if origin == _target:
		return
	
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x: Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break
	
	if up != Vector3.ZERO:
		_node.look_at(_target, up)

# overridable to allow for certain npcs to process damage differently/set targets
func on_hurt(damage):
	health.health -= damage.amount
	if damage.source and will_retaliate:
		target = damage.source
		current_state = STATE.ATTACK

# virtual method
func process_idle_state(_delta):
	# move to starting position
	pass

# virtual method
func process_patrol_state(_delta):
	# choose random patrol point in PatrolPoints node and move to it
	pass

# virtual method
func process_attack_state(_delta):
	# if target is valid, move within attack range and perform attack based on accuracy(if ranged)
	pass

func kill():
	var corpse = Globals.create_corpse(self)
	corpse.global_transform.origin = global_transform.origin
	corpse.init_inventory_size(inventory_data.slot_datas.size())
	for item in inventory_data.slot_datas:
		if item:
			corpse.inventory.add_item(item)
	queue_free()

func randomize_loot():
	var random_amount = randi() % loot_table.size()
	for _i in range(0, random_amount):
		var new_slot = SlotData.new()
		var random_item = loot_table[randi() % loot_table.size()] # choose a random item
		new_slot.item_data = random_item
		inventory_data.add_item(new_slot)

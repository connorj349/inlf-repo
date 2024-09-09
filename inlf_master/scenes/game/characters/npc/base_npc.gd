extends CharacterBody3D

enum State { IDLE, PATROL, ATTACK, INSPECT, RUN_AWAY }

const FOOTSTEP_FREQUENCY: float = 75.0
# how far away the player needs to be until this npc stops running away
const FEAR_DISTANCE: float = 20.0
# minimum distance to try to flee away from the player
const FLEE_DISTANCE: float = 20.0

@export var inventory_data: Resource
@export var loot_table: Array[ItemData]
@export var will_retaliate = true
@export var will_inspect = true
# used for antagonist npcs that will attack the player/other npcs on sight
@export var hostile = false
@export var damage: Damage
# represents the state this ai will default to when not busy
@export var default_state = State.IDLE

var current_state = State.IDLE
var target = null
var patrol_index: int = 0
# use current_speed with constants for idle_speed, run_speed, etc.
var speed: float = 2.0
var attack_time: float = 0.0
var footstep_time: float = 0.0
var patrol_points: Array[Node3D]

@onready var health = $Health
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_range_area: CollisionShape3D = $AttackRangeArea/CollisionShape3D
@onready var npc_animations_player: AnimationPlayer = $korpsman/AnimationPlayer

func _ready():
	if !is_in_group("npc"):
		add_to_group("npc")
	
	for patrol_point in get_tree().get_nodes_in_group("patrol_points"):
		patrol_points.append(patrol_point)
	
	randomize()
	health.init()
	health.connect("dead", Callable(self, "_kill"))
	
	_randomize_loot()
	
	# prevents error on startup from processing finding new paths in physics_process
	set_physics_process(false)
	set_process(false)
	await get_tree().physics_frame
	await get_tree().process_frame
	set_physics_process(true)
	set_process(true)
	
	call_deferred("_wander_to_random_position")

func _process(delta):
	match(current_state):
		State.IDLE:
			process_idle_state(delta)
		State.PATROL:
			process_patrol_state(delta)
		State.ATTACK:
			process_attack_state(delta)
		State.INSPECT:
			process_inspect_state(delta)
		State.RUN_AWAY:
			process_run_away_state(delta)

func _physics_process(_delta):
	if navigation_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * speed
	
	_safe_look_at(self, next_path_position)
	rotate_object_local(Vector3.UP, PI)
	
	move_and_slide()
	
	if velocity.length() > 0:
		footstep_time += velocity.length()
		
		if footstep_time >= FOOTSTEP_FREQUENCY:
			footstep_time = 0.0
			$FootstepSound.play()

##
## state methods
##

# virtual method
func process_idle_state(_delta):
	await navigation_agent.navigation_finished
	
	if default_state == State.PATROL:
		current_state = State.PATROL
		return
	
	if navigation_agent.is_navigation_finished():
		npc_animations_player.play("Idle")
		await get_tree().create_timer(2.0).timeout
		_wander_to_random_position()
		return

# virtual method
func process_patrol_state(_delta):
	if navigation_agent.is_navigation_finished():
		if patrol_points.size() > 0:
			#var random_index = randi_range(0, patrol_points.size() - 1)
			
			_set_target_movement(patrol_points[patrol_index].global_transform.origin)
			patrol_index = (patrol_index + 1) % patrol_points.size()
		else:
			# if there are no patrol points, default to IDLE state
			current_state = State.IDLE

# virtual method
func process_attack_state(delta):
	attack_time -= delta
	
	# this doesn't work and is never the case, the AI never goes back to IDLE
	if target == null:
		current_state = State.IDLE
		_wander_to_random_position()
		return
	
	if navigation_agent.is_navigation_finished():
		_safe_look_at(self, target.position)
		rotate_object_local(Vector3.UP, PI)
		
		if attack_time <= 0.0:
			_attack()
			# reset attack interval
			attack_time = 1.0
	else:
		if global_transform.origin.distance_to(target.position) < attack_range_area.shape.radius:
			_set_target_movement(global_transform.origin)

# virtual method
func process_inspect_state(_delta):
	# turn the below into a method
	if !navigation_agent.is_navigation_finished():
		# stop moving
		_set_target_movement(global_transform.origin)
		npc_animations_player.play("Idle")
	
	_safe_look_at(self, target.position)
	rotate_object_local(Vector3.UP, PI)

func process_run_away_state(_delta):
	if target == null:
		current_state = State.IDLE
		_wander_to_random_position()
		return
	
	if navigation_agent.is_navigation_finished():
		if global_transform.origin.distance_to(target.position) <= FEAR_DISTANCE:
			_run_away_from_target(target)
			speed = 8
		else:
			current_state = State.IDLE
			speed = 2
			_wander_to_random_position()
			target = null

##
## base fuctionality methods
##

# overridable to allow for certain npcs to process damage differently/set targets
func on_hurt(_damage):
	health.health -= _damage.amount
	
	if _damage.source and will_retaliate:
		current_state = State.ATTACK
	else:
		current_state = State.RUN_AWAY
	
	target = _damage.source

func _chase():
	if is_instance_valid(target):
		if target and global_transform.origin.distance_to(target.position) > attack_range_area.shape.radius:
			_set_target_movement(target.position)
			# set chase speed
			speed = 4.0
		else:
			_attack()
	else:
		current_state = State.IDLE
		speed = 2.0
		_wander_to_random_position()

# overridable to allow for different npcs to use different attacks (melee/ranged)
func _attack():
	if is_instance_valid(target):
		if global_transform.origin.distance_to(target.position) < attack_range_area.shape.radius:
			# stop moving
			_set_target_movement(global_transform.origin)
			
			if target.has_method("on_hurt"):
				npc_animations_player.play("Shooting")
				
				await npc_animations_player.animation_finished
				
				target.on_hurt(damage)
		else:
			_chase()
	else:
		current_state = State.IDLE
		speed = 2.0
		_wander_to_random_position()

func _run_away_from_target(_target: Node3D):
	var direction_to_target = (target.global_position - global_position).normalized()
	var flee_direction = -direction_to_target
	
	var random_offset = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized()
	
	var random_point = global_position + (flee_direction + random_offset).normalized() * FLEE_DISTANCE
	
	_set_target_movement(random_point)

func _wander_to_random_position():
	await get_tree().physics_frame
	
	var random_target_position = global_position + Vector3(randi_range(-5, 5), 0, randi_range(-5, 5))
	
	_set_target_movement(random_target_position)

func _set_target_movement(movement_target: Vector3):
	navigation_agent.set_target_position(_get_point_on_map(movement_target, 0.5))
	npc_animations_player.play("Run")

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

# prevents weird behavior and allows npc to look at target position
# should also call rotate_object_local(Vector3.UP, PI) after this method
# to allow the npc to also rotate the model in the correct direction
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

# do not want to override this method
func _kill():
	var corpse = load("res://scenes/game/characters/corpse.tscn").instantiate()
	get_tree().current_scene.game_world.add_child(corpse)
	corpse.global_transform.origin = global_transform.origin
	
	corpse.init_inventory_size(inventory_data.slot_datas.size())
	
	for item in inventory_data.slot_datas:
		if item:
			corpse.inventory.add_item(item)
	
	queue_free()

# setups random loot on this npc using loot_table/ do not want to override this method
func _randomize_loot():
	var random_amount = randi() % loot_table.size()
	for _i in range(0, random_amount):
		var new_slot = SlotData.new()
		var random_item = loot_table[randi() % loot_table.size()] # choose a random item
		new_slot.item_data = random_item
		inventory_data.add_item(new_slot)

# virtual method?
func _on_inspect_area_body_entered(body):
	if current_state != State.IDLE:
		# don't bother insepcting if attacking
		return
	
	if will_inspect:
		current_state = State.INSPECT
		target = body

# virtual method?
func _on_inspect_area_body_exited(_body):
	if current_state == State.ATTACK or current_state == State.RUN_AWAY:
		return
	
	# turn the below into a match statement
	if current_state == State.INSPECT:
		current_state = State.IDLE
		target = null
		_wander_to_random_position()

# virtual method?
func _on_attack_range_area_body_entered(_body):
	if current_state != State.ATTACK:
		if hostile:
			current_state = State.ATTACK
			target = _body
			_attack()
			speed = 8
		return
	
	_attack()

# virtual method?
func _on_attack_range_area_body_exited(_body):
	if current_state != State.ATTACK:
		return
	
	_chase()

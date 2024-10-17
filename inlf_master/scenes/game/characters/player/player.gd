extends CharacterBody3D

signal armor_changed(armor: int)

const SPEED_WALK: float = 10.0
const JUMP_VELOCITY: float = 5.0
const FOOTSTEP_FREQUENCY: float = 25
const SENSITIVITY: float = 0.1
const MAX_STEP_HEIGHT: float = 0.5
const CROUCH_TRANSLATE: float = 0.7
const CROUCH_JUMP_ADD: float = CROUCH_TRANSLATE * 0.9

# need to reset these on gameover as well
@export var inventory_data: InventoryData
@export var weapon_inventory_data: InventoryDataWeapon
@export var armor_inventory_data: InventoryDataEquip

var armor: int = 0 :
	set(_value):
		armor = clampi(_value, 0, 25)
		armor_changed.emit(armor)
		update_armor_bar_visibility()
var pickup_object = null
var speed
var gravity: float = 9.8
var footstep_time = 0
var is_crouched = false
var _snapped_to_stairs_last_frame = false
var _last_frame_was_on_floor = -INF
var _saved_camera_global_pos = null

@onready var _original_capsule_height = $CollisionShape3D.shape.height

@onready var camera: Camera3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D

@onready var health: Node3D = $Health
@onready var head: Node3D = $HeadOriginalPosition
@onready var camera_smooth: Node3D = $HeadOriginalPosition/Head/CameraSmooth
@onready var hold_object_pos: Node3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D/PickupRayCast/HoldObjectPosition
@onready var weapon_manager: Node3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D/WeaponManager

@onready var interact_area: Area3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D/InteractArea

@onready var hint_raycast: RayCast3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D/HintObjRayCast
@onready var pickup_raycast: RayCast3D = $HeadOriginalPosition/Head/CameraSmooth/Camera3D/PickupRayCast
@onready var ground_raycast: RayCast3D = $GroundRaycast
@onready var stairs_ahead_raycast: RayCast3D = $StairsAheadRaycast3D
@onready var stairs_below_raycast: RayCast3D = $StairsBelowRaycast3D

@onready var health_bar: TextureProgressBar = $UI/Bars/health_pox/health_bar
@onready var pox_bar: TextureProgressBar = $UI/Bars/health_pox/pox_bar
@onready var armor_bar: TextureProgressBar = $UI/Bars/health_pox/armor_background/armor_bar

@onready var player_dead_prefab: PackedScene = load("res://scenes/game/characters/player/player_dead.tscn")


func _ready():
	health.init()
	health.connect("health_changed", Callable(health_bar, "update_bar"))
	health.connect("max_health_changed", Callable(func(player_health, player_max_health):
		health_bar.init(player_health, player_max_health + health.pox)))
	health.connect("max_health_changed", Callable(self, "update_health_and_pox_text_placement").unbind(2))
	health.connect("pox_changed", Callable(pox_bar, "update_bar"))
	health.connect("pox_changed", Callable(self, "update_health_and_pox_text_placement").unbind(1))
	health.connect("dead", Callable(self, "kill"))
	
	health_bar.init(health.health, health.max_health)
	pox_bar.init(health.pox, health.allowed_max_health)
	
	connect("armor_changed", Callable(armor_bar, "update_bar"))
	connect("armor_changed", Callable(self, "update_armor_bar_visibility").unbind(1))
	update_armor_bar_visibility()
	
	Globals.current_player = self

func _input(event):
	if !player_is_in_menu():
		if event is InputEventMouseMotion:
			head.rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
			camera.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

@warning_ignore("unused_parameter")
func _process(delta):
	# toggle inventory menu
	if Input.is_action_just_pressed("inventory"):
		Globals.emit_signal("on_inventory_toggle")
		
		$Sounds/InventoryOpenSound.play()
	
	# interacting
	if Input.is_action_just_pressed("interact") and !player_is_in_menu():
		if pickup_object:
			pickup_object = null
		
		if interact_area.monitoring:
			for body in interact_area.get_overlapping_bodies():
				if body.has_method("_interact"):
					body._interact(self) #calls the interact method on the interactable, passing self as arg
	
	if !player_is_in_menu():
		if Input.is_action_just_pressed("left_click"):
			weapon_manager.attack()
		
		# picking up interactable physicsbodies, later add alternate firemodes for weapons
		if Input.is_action_just_pressed("right_click"):
			if is_instance_valid(pickup_object):
				pickup_object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
				pickup_object.freeze = false
				pickup_object.collision_mask = 1 | 2
				pickup_object = null
			elif pickup_raycast.get_collider() and pickup_raycast.get_collider() is RigidBody3D:
				pickup_object = pickup_raycast.get_collider()
				pickup_object.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
				pickup_object.freeze = true
				pickup_object.collision_mask = 0
				if pickup_object.has_method("play_pickup_sound"):
					pickup_object.play_pickup_sound()
		
		# update the pickup object position as long as the object is valid
		if is_instance_valid(pickup_object):
			pickup_object.global_transform.origin = hold_object_pos.global_transform.origin
		
		# weapon switching
		if Input.is_action_just_pressed("switch_weapons"):
			weapon_manager.switch_to_next_weapon()
		
		# reloading
		if Input.is_action_just_pressed("reload"):
			weapon_manager.reload()
		
		# jumping
		if Input.is_action_just_pressed("jump") and (is_on_floor() or _snapped_to_stairs_last_frame):
			velocity.y = JUMP_VELOCITY
			
			$Sounds/JumpSoundQueue.PlaySoundRange(0.9, 1.1)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	_handle_crouch(delta)
	
	if is_crouched:
		speed = SPEED_WALK * 0.8
	else:
		speed = SPEED_WALK
	
	if is_on_floor() or _snapped_to_stairs_last_frame:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	if not _snap_up_stairs_check(delta):
		# because _snap_up_stairs_check moves the body manually, don't call move_and_slide
		# this should be fine since we ensure with the body_test_motion that it doesnt'
		# collide with anything except the stairs it's moving up to.
		move_and_slide()
		
		_snap_down_to_stairs_check()
	
	_slide_camera_smooth_back_to_origin(delta)
	
	#footstep calculating
	if direction.length() > 0:
		footstep_time += direction.length()
		
		if footstep_time >= FOOTSTEP_FREQUENCY:
			footstep_time = 0
			_footstep()
	
	# shows the info from the hintobject onscreen
	var coll = hint_raycast.get_collider()
	if is_instance_valid(coll):
		if hint_raycast.is_colliding() and coll.has_method("_look_at"):
			coll._look_at()

# need to redo this
func update_health_and_pox_text_placement():
	for element in $UI/Bars/health_pox/pox_bar/VBoxContainer.get_children():
		element.text = ""
	if health.max_health > health.allowed_max_health * 0.5:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label3.text = "blood"
	elif health.max_health > health.allowed_max_health * 0.25:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label2.text = "blood"
	elif health.max_health > 0:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label.text = "blood"
	if health.pox > health.allowed_max_health * 0.5:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label3.text = "POX"
	elif health.pox > health.allowed_max_health * 0.25:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label4.text = "POX"
	elif health.pox > 0:
		$UI/Bars/health_pox/pox_bar/VBoxContainer/Label5.text = "POX"

func update_armor_bar_visibility():
	if armor <= 0:
		$UI/Bars/health_pox/armor_background.visible = false
	else:
		$UI/Bars/health_pox/armor_background.visible = true

# used by all other objects that want to hurt the player
func on_hurt(damage):
	if armor > 0:
		armor -= damage.amount
		$Sounds/ArmorHitSound.play()
	else:
		deal_damage(damage)
		$Sounds/HurtSound.play()

# used by armor to actually deal damage to the player, does this when no more armor
func deal_damage(damage):
	if health.health > 0:
		health.health -= damage.amount

# mainly used by slotdataconsumable and autostitcher
func on_heal(amount, play_sound = false):
	health.health += amount
	if play_sound:
		$Sounds/HealSound.play()

# used by some consumables
func give_armor(amount):
	armor += amount
	$Sounds/GainArmorSound.play()

# use functionality of items
func use_slot_data(slot_data):
	slot_data.item_data.use(self)

# expand, maybe override on player_cultist for additional effects?
func on_use_organ(_organ):
	pass

func _handle_crouch(delta):
	var was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("crouch"):
		is_crouched = true
	elif is_crouched and not self.test_move(self.global_transform, Vector3(0, CROUCH_TRANSLATE, 0)):
		is_crouched = false
	
	var translate_y_if_possible: float = 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor() and not _snapped_to_stairs_last_frame:
		translate_y_if_possible = CROUCH_JUMP_ADD if is_crouched else -CROUCH_JUMP_ADD
	
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.global_transform, Vector3(0, translate_y_if_possible, 0), result)
		self.position.y += result.get_travel().y
		%Head.position.y = clampf(%Head.position.y, -CROUCH_TRANSLATE, 0.0)
	
	%Head.position.y = move_toward(%Head.position.y, -CROUCH_TRANSLATE if is_crouched else 0.0, 7.0 * delta)
	$CollisionShape3D.shape.height = _original_capsule_height - CROUCH_TRANSLATE if is_crouched else _original_capsule_height
	$CollisionShape3D.position.y = $CollisionShape3D.shape.height / 2

# checking if stairs/floor is too steep to step down
func is_surface_too_steep(normal: Vector3):
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

# from tutorial
func _snap_up_stairs_check(delta):
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	# we give some clearance above to ensure there's ample room for the player.
	# if it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	# along with their intended motion foward.
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (_run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# note, step_height <= 0.01 just because it prevented some phsyics glitchiness
		# 0.02 was found with trial and error, too much and sometimes get stuck on a stair, too little and can jitter if running into a ceiling.
		# the normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height < 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		stairs_ahead_raycast.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_raycast.force_raycast_update()
		if stairs_ahead_raycast.is_colliding() and not is_surface_too_steep(stairs_ahead_raycast.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

# from tutorial
func _snap_down_to_stairs_check():
	var did_snap = false
	var floor_below: bool = stairs_below_raycast.is_colliding() and not is_surface_too_steep(stairs_below_raycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null):
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = camera_smooth.global_position

func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null: return
	
	camera_smooth.global_position.y = _saved_camera_global_pos.y
	camera_smooth.position.y = clampf(camera_smooth.position.y, -0.7, 0.7) # clamp when teleported
	var move_amount = max(self.velocity.length() * delta, SPEED_WALK / 2 * delta)
	camera_smooth.position.y = move_toward(camera_smooth.position.y, 0.0, move_amount)
	_saved_camera_global_pos = camera_smooth.global_position
	if camera_smooth.position.y == 0:
		_saved_camera_global_pos = null # stop smoothing camera

# check the tile, play the sound, all timing is done in _process
func _footstep():
	var coll_tileset = ground_raycast.get_collider()
	if ground_raycast.is_colliding():
		if coll_tileset.is_in_group("ground_stone"):
			$Sounds/Footsteps/StoneFootstep.play()
		elif coll_tileset.is_in_group("ground_transition"):
			$Sounds/Footsteps/TileFootstep.play()
		elif coll_tileset.is_in_group("ground_mud"):
			$Sounds/Footsteps/MudFootstep.play()

func kill():
	# hides the player's inventory screen on death
	Globals.current_ui.visible = false
	
	# hide player mouse if visible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# create the player corpse
	var corpse = load("res://scenes/game/characters/corpse.tscn").instantiate()
	get_tree().current_scene.game_world.add_child(corpse)
	
	# place the corpse correctly on the ground
	if is_on_floor():
		corpse.global_transform.origin = global_transform.origin
	else:
		corpse.global_transform.origin = ground_raycast.get_collision_point()
	
	corpse.init_inventory_size(inventory_data.slot_datas.size() + armor_inventory_data.slot_datas.size() + weapon_inventory_data.slot_datas.size())
	
	# create the player dead gameobject
	var player_dead = player_dead_prefab.instantiate()
	get_tree().current_scene.game_world.add_child(player_dead)
	player_dead.global_transform.origin = corpse.global_transform.origin + Vector3.UP
	
	# add armor to corpse inventory and reset armor slot
	if armor_inventory_data.slot_datas[0]: # prevent errors
		corpse.inventory.add_item(armor_inventory_data.slot_datas[0])
		armor_inventory_data.take_item(armor_inventory_data.slot_datas[0])
	
	# add all weapons to the corpse inventory and reset weapon slots
	for wep in weapon_inventory_data.slot_datas:
		if wep:
			corpse.inventory.add_item(wep)
			weapon_inventory_data.take_item(wep)
	
	# add all items to the corpse inventory and reset inventory
	for item in inventory_data.slot_datas:
		if item:
			corpse.inventory.add_item(item)
			inventory_data.take_item(item)
	
	# reset spawn time and play the player's death sound
	player_dead.get_node("PlayerSpawnTimer").wait_time = corpse.get_node("DecayTimer").wait_time
	player_dead.play_death_sound()
	
	queue_free() #remove the player

#where to drop items relative to player looking position
func get_drop_position():
	var direction = -camera.global_transform.basis.z
	return camera.global_transform.origin + direction

func player_is_in_menu(): #returns true if the player's mouse is showing
	match[Input.get_mouse_mode()]:
		[Input.MOUSE_MODE_CONFINED]:
			return true
		[Input.MOUSE_MODE_CAPTURED]:
			return false

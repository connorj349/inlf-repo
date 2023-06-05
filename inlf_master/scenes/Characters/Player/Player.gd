extends KinematicBody

# update how damage calculation is done depending on the armor being work in player_equipment_inventory

export var mouse_sensitivity = 0.1

onready var head = $Head
onready var camera = $Head/Camera
onready var interact_area = $Head/Camera/InteractArea
onready var movement = $Movement
onready var health = $Health
onready var hint_raycast = $Head/Camera/HintObjRayCast
onready var weapon_manager = $Head/Camera/WeaponManager
onready var ground_cast = $GroundRayCast

onready var health_bar = $UI/Bars/health_bar

var cam_accel = 40

var footstep_time = 0 #move footsteps to a component so NPCs can have this functionality
var footstep_freq = 25

var player_dead_prefab = preload("res://scenes/Characters/Player/Player_Dead.tscn") #for player view while dead

func _ready():
	movement.init(self) #allow motion
	#health.connect("hurt", something, "play_hurt_effects") #enable effects when player is damaged like sound/hud
	health.init() #setup sarting health
	health.connect("health_changed", health_bar, "update_bar") #setup healthbar connection
	health.connect("dead", self, "kill")
	health_bar.init(health.health, health.max_health)
	Globals.current_player = self

func on_hurt(amount): #used by all other objects that want to hurt the player
	health.hurt(amount)

func on_heal(amount): #mainly used by slotdataconsumable and autostitcher
	health.heal(amount)

func _input(event):
	if !player_is_in_menu(): #only move player head while not in a menu
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _process(delta):
	if Input.is_action_just_pressed("debug_kill"): #debug kill
		kill()
	#toggle inventory menu
	if Input.is_action_just_pressed("inventory"):
		Globals.emit_signal("on_inventory_toggle")
	#interacting
	if Input.is_action_just_pressed("interact") and !player_is_in_menu():#change this so it's a raycast instead of area
		if interact_area.monitoring:
			for body in interact_area.get_overlapping_bodies():
				if body.is_in_group("interactable"):
					if body._interact(self): #calls the interact method on the interactable, passing self as arg
						pass
	if !player_is_in_menu(): #only allow these actions when not in a menu
		#attacking
		if Input.is_action_just_pressed("left_click"):
			weapon_manager.attack()
		#weapon switching
		if Input.is_action_just_pressed("switch_weapons"):
			weapon_manager.switch_to_next_weapon()
		#reloading
		if Input.is_action_just_pressed("reload"):
			weapon_manager.reload()
		#jumping
		if Input.is_action_just_pressed("jump") and is_on_floor():
				movement.jump()
		#movement
		var direction = Vector3.ZERO
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = Vector3(h_input, 0, f_input)
		movement.set_move_vector(direction)
		#footsteps move this to it's own component
		if is_on_floor() and direction.length() > 0: #footstep calculating
			footstep_time += direction.length()
			if footstep_time >= footstep_freq:
				footstep_time = 0
				footstep()
	else:
		movement.set_move_vector(Vector3.ZERO) #set movement to zero when in menu
	camera_physics_interpolation(delta) #camera smoothing from tutorial

func _physics_process(_delta): #only used for hintobject
	var coll = hint_raycast.get_collider()
	if hint_raycast.is_colliding() and coll.has_method("_look_at"): #shows the info from the hintobject onscreen
		coll._look_at()

func footstep(): #check the tile, play the sound, all timing is done in _process
	var coll_tileset = ground_cast.get_collider()
	if ground_cast.is_colliding():
		if coll_tileset.is_in_group("ground_stone"):
			$step_stone.pitch_scale = rand_range(0.7, 1.3)
			$step_stone.play()
		elif coll_tileset.is_in_group("ground_transition"):
			$step_transition.pitch_scale = rand_range(0.7, 1.3)
			$step_transition.play()
		elif coll_tileset.is_in_group("ground_mud"):
			$step_mud.pitch_scale = rand_range(0.7, 1.3)
			$step_mud.play()

func use_slot_data(slot_data): #use functionality of items
	slot_data.item_data.use(self) #activate the use function on the item's data, passing the player

func kill(): #move this functionality to a component, then hook up health "death" signal to kill component
	#remove the below and make a better way to drop/remove player items
	Gamestate.equip_player_inventory.slot_datas[0] = null
	Gamestate.equip_player_inventory.emit_signal("inventory_updated", Gamestate.equip_player_inventory)
	Gamestate.weapon_player_inventory.slot_datas[0] = null
	Gamestate.weapon_player_inventory.emit_signal("inventory_updated", Gamestate.weapon_player_inventory)
	
	Globals.current_ui.visible = false #hides the player's inventory screen on death
	if Globals.current_ui.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #hide player mouse if visible
	var player_dead = player_dead_prefab.instance() #create the death view
	get_tree().get_root().add_child(player_dead)
	player_dead.global_transform = Globals.current_player.global_transform
	var corpse = Globals.create_corpse(self)
	player_dead.get_node("PlayerSpawnTimer").wait_time = corpse.get_node("DecayTimer").wait_time #reset spawn time
	player_dead.play_death_sound(self)
	queue_free() #remove this player object

func get_drop_position(): #where to drop items relative to player looking position
	var direction = -camera.global_transform.basis.z
	return camera.global_transform.origin + direction

func player_is_in_menu(): #returns true if the player's mouse is showing
	match[Input.get_mouse_mode()]:
		[Input.MOUSE_MODE_CONFINED]:
			return true
		[Input.MOUSE_MODE_CAPTURED]:
			return false

func camera_physics_interpolation(delta): #followed tutorial for this
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform

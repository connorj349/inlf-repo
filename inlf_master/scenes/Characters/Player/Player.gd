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

onready var health_bar = $UI/Bars/health_bar

onready var portrait_image = $UI/CharacterPortrait/margin_container/portrait_image
var role

var cam_accel = 40

var player_dead_prefab = preload("res://scenes/Characters/Player/Player_Dead.tscn") #for player view while dead
var blood_circle_prefab = preload("res://scenes/Misc/blood_circle.tscn")

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

func set_role(_role): # setup role; maybe add sound to it?
	role = _role # for use with checking if player can use certain machines/objects
	portrait_image.texture = role.portrait_image # cosmetic

func spawn_circle_of_blood(): # only can be done if cultist role
	#needs a cooldown so the player cannot commit suicide easily
	if role.name == "cultist":
		Globals.emit_signal("on_pop_notification", "I cut open my skin, creating a blood circle.")
		on_hurt(health.max_health / 2)
		var circle = blood_circle_prefab.instance()
		get_tree().get_root().add_child(circle)
		# need a better way of spawning the blood circle
		# play blood splatter/drip noise
		circle.global_transform.origin = hint_raycast.get_collision_point()
	else:
		Globals.emit_signal("on_pop_notification", "Why would I cut my skin open?")

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
	if Input.is_action_just_pressed("draw_circle"):
		spawn_circle_of_blood()
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
	else:
		movement.set_move_vector(Vector3.ZERO) #set movement to zero when in menu
	camera_physics_interpolation(delta) #camera smoothing from tutorial

func _physics_process(_delta): #only used for hintobject
	var coll = hint_raycast.get_collider()
	if hint_raycast.is_colliding() and coll.has_method("_look_at"): #shows the info from the hintobject onscreen
		coll._look_at()

func use_slot_data(slot_data): #use functionality of items
	slot_data.item_data.use(self) #activate the use function on the item's data, passing the player

func kill(): #move this functionality to a component, then hook up health "death" signal to kill component
	#remove the below and make a better way to drop/remove player items
	Gamestate.equip_player_inventory.take_item(Gamestate.equip_player_inventory.slot_datas[0])
	Gamestate.weapon_player_inventory.take_item(Gamestate.weapon_player_inventory.slot_datas[0])
	for slot_data in Gamestate.player_inventory.slot_datas: # take items from inventory
		if slot_data:
			if slot_data.item_data.drop_on_death:
				Gamestate.player_inventory.take_item(slot_data)
	
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

extends KinematicBody

export var mouse_sensitivity = 0.1 # make this into global variable

onready var head = $Head
onready var camera = $Head/Camera
onready var interact_area = $Head/Camera/InteractArea
onready var movement = $Movement
onready var health = $Health
onready var magick = $Magick
onready var armor = $Armor
onready var hint_raycast = $Head/Camera/HintObjRayCast
onready var weapon_manager = $Head/Camera/WeaponManager

onready var health_bar = $UI/Bars/health_bar
onready var magick_amount_left = $UI/MagickLabel
var role # player role

var cam_accel = 40

var blood_circle_active = false

var player_dead_prefab = preload("res://Characters/Player/Player_Dead.tscn") #for player view while dead
var blood_circle_prefab = preload("res://gameobjects/blood_circle.tscn") #to spawn when player is cultist

func _ready():
	movement.init(self) #allow motion
	#health.connect("hurt", something, "play_hurt_effects") #enable effects when player is damaged like sound/hud
	health.init() #setup sarting health
	health.connect("health_changed", health_bar, "update_bar") #setup healthbar connection
	health.connect("dead", self, "kill") # setup death functionality
	health_bar.init(health.health, health.max_health)
	armor.init()
	armor.connect("damage_dealt", self, "deal_damage")
	#armor.connect("armor_changed", self, "update_armor_bar")
	Globals.current_player = self
# warning-ignore:return_value_discarded
	Globals.connect("blood_circle_removed", self, "on_blood_circle_removed")
	yield(get_tree(), "idle_frame") # prevents errors for next part
	if role.role_type == Role.Role_Type.Cultist:
		magick.init(2) # only provide the player mana if they are an antagonist
		magick_amount_left.text = str(magick.curr_magick)
	else:
		magick.init(0)
		magick_amount_left.visible = false
	magick.connect("magick_changed", self, "on_magick_changed")

func on_hurt(damage): #used by all other objects that want to hurt the player
	armor.calc_damage(damage.amount) # calc actual damage dealt, then call deal_damage

func deal_damage(amount): # used by armor to actually deal damage to the player, does this when no more armor
	health.hurt(amount)

func on_heal(amount): #mainly used by slotdataconsumable and autostitcher
	health.heal(amount)

func give_armor(amount): # used by some consumables
	var armor_to_give_player = 0 # begin at zero
	if Gamestate.equip_player_inventory:
		var total_base_allowed = Gamestate.equip_player_inventory.armor_added + Globals.player_base_armor
		armor_to_give_player = clamp(armor_to_give_player + amount, 0, total_base_allowed)
		armor.add_armor(armor_to_give_player)
	else:
		armor_to_give_player = clamp(armor_to_give_player + amount, 0, Globals.player_base_armor)
		armor.add_armor(armor_to_give_player)

func on_blood_circle_removed():
	blood_circle_active = false

func on_use_organ(organ):
	if blood_circle_active:
		if magick.curr_magick >= organ.mana_regen:
			Globals.emit_signal("cast_spell", organ)
			magick.modify_magick(-organ.mana_regen)
			# SoundManager.play_castspell
	else:
		if role.role_type == Role.Role_Type.Cultist:
			magick.modify_magick(organ.mana_regen)
			# SoundManager.play_manaregen
		else:
			deal_damage(15) # arbituary amount, could make this a global or based on the item consumed
			# SoundManager.use_organeat

func set_role(_role): # setup role; maybe add sound to it?
	role = _role # for use with checking if player can use certain machines/objects

func on_magick_changed(curr_magick): # update UI for magic remaining
	magick_amount_left.text = str(curr_magick)

func spawn_circle_of_blood(): # only can be done if cultist role
	if !blood_circle_active:
		if role.role_type == Role.Role_Type.Cultist:
			Globals.emit_signal("on_pop_notification", "I cut open my skin, creating a blood circle.")
			deal_damage(health.max_health / 2)
			var circle = blood_circle_prefab.instance()
			get_tree().get_root().add_child(circle)
			# SoundManager.other_bloodcircle_spawn
			circle.global_transform = $feet.global_transform
			blood_circle_active = true
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
	# spawn blood circle
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

func kill():
	Gamestate.reset_player_equipment() # remove weapon and armor from player
	for slot_data in Gamestate.player_inventory.slot_datas: # take items from inventory if checked
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
	player_dead.play_death_sound()
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

extends Node3D

@export var is_melee: bool = false # determines if we need to play onhit sounds
@export var item_weapon_data: ItemDataWeapon = null
@export var fire_sound: AudioStreamPlayer

var ammo = 0
var item_weapon_damage = Damage.new()

@onready var anim_player = $WeaponAnimations
@onready var raycast = $RangeRayCast
@onready var sprite = $CanvasLayer/Control/Sprite2D
@onready var player = $"../../../../../.."

func _ready():
	call_deferred("_setup_damage_source")

func toggle_visibility(_visible: bool):
	sprite.visible = _visible

func on_attack():
	if item_weapon_data:
		if !anim_player.is_playing(): #this allows the animplayer to be kinda like the attackspeed
			anim_player.play("attack")
			
			ammo -= 1 #remove ammo
			
			if fire_sound:
				fire_sound.play()
				
			var col = raycast.get_collider()
			if raycast.is_colliding() and col.has_method("on_hurt"):
				col.on_hurt(item_weapon_damage)

func reload(inventory_data: InventoryData):
	if item_weapon_data:
		if !anim_player.is_playing():
			anim_player.play("reload")
			
			var ammo_needed = item_weapon_data.max_ammo - ammo
			for i in ammo_needed:
				if inventory_data.take_item(item_weapon_data.ammo_slot):
					ammo += 1
				else:
					return #stop trying to take ammo

func _setup_damage_source():
	await get_tree().physics_frame
	
	item_weapon_damage.type = item_weapon_data.damage_type
	item_weapon_damage.amount = item_weapon_data.damage
	item_weapon_damage.source = player

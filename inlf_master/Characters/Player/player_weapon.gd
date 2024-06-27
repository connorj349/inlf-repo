extends Node3D

@export var is_melee: bool = false #determines if we need to play onhit sounds
@export var item_weapon_data: Resource = null

@onready var anim_player = $AnimationPlayer
@onready var raycast = $RangeRayCast
@onready var sprite = $CanvasLayer/Control/Sprite2D

var ammo = 0
var item_weapon_damage = Damage.new()

func _ready():
	# set collision masks to 1, 2, and NPC
	# raycast.collision_mask
	item_weapon_damage.type = item_weapon_data.damage_type
	item_weapon_damage.amount = item_weapon_data.damage
	item_weapon_damage.source = Globals.current_player

func on_attack():
	if item_weapon_data:
		if !anim_player.is_playing(): #this allows the animplayer to be kinda like the attackspeed
			anim_player.play("attack")
			ammo -= 1 #remove ammo
			# play weapon sounds
			var col = raycast.get_collider()
			if raycast.is_colliding() and col.has_method("on_hurt"):
				col.on_hurt(item_weapon_damage)

func reload(inventory_data: InventoryData): #need to play sound somewhere
	if item_weapon_data:
		if !anim_player.is_playing():
			var ammo_needed = item_weapon_data.max_ammo - ammo
			for i in ammo_needed:
				if inventory_data.take_item(item_weapon_data.ammo_slot):
					ammo += 1
				else:
					return #stop trying to take ammo

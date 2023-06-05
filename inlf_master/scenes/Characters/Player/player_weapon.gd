extends Spatial

# ADD current magazine size and max magazine size for attacking
# ADD calibers, damage types(maybe)

export(bool) var is_melee = false #determines if we need to play onhit sounds
export(Resource) var item_weapon_data = null

onready var anim_player = $AnimationPlayer
onready var raycast = $RangeRayCast
onready var sprite = $CanvasLayer/Control/Sprite

var ammo = 0

func on_attack():
	if item_weapon_data:
		if !anim_player.is_playing(): #this allows the animplayer to be kinda like the attackspeed
			anim_player.play("attack")
			ammo -= 1 #remove ammo
			# play weapon sounds
			var col = raycast.get_collider()
			if raycast.is_colliding() and col.has_method("on_hurt"):
				col.on_hurt(item_weapon_data.damage)

func reload(inventory_data: InventoryData): #need to play sound somewhere
	var ammo_needed = item_weapon_data.max_ammo - ammo
	for i in ammo_needed:
		if inventory_data.take_item(item_weapon_data.ammo_slot):
			ammo += 1
		else:
			return #stop trying to take ammo

func hide():
	sprite.visible = false

func show():
	sprite.visible = true

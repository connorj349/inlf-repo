extends Spatial

# change how equipping weapons work, uses an item slot instead? that is special for player/destroyed on death?
# ADD current magazine size and max magazine size for attacking
# ADD calibers, damage types(maybe)

export(bool) var is_melee = false #determines if we need to play onhit sounds
export(int) var damage = 0
export(String) var weapon_item_id = "10001"

onready var anim_player = $AnimationPlayer
onready var raycast = $RangeRayCast
onready var sprite = $CanvasLayer/Control/Sprite

var is_owned = false

func on_attack():
	if !anim_player.is_playing(): #this allows the animplayer to be kinda like the attackspeed
		anim_player.play("attack")
		if is_melee:
			if raycast.is_colliding():
				#play melee hit sounds
				pass
		var col = raycast.get_collider()
		if raycast.is_colliding() and col.has_method("on_hurt"):
			col.on_hurt(damage)

func hide():
	sprite.visible = false

func show():
	sprite.visible = true

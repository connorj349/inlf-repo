extends Storage

# derive from storage; does not have its own inventory data, references global_merchant_inventory
# add functionality for items to be purchased instead of just grabbed???

#onready var anim_player = $AnimationPlayer

#func _display_info(): #override, can even add sounds to this as it's not played dozens of times
	#anim_player.play("fade_in")

#func _hide_info(): #play animation in reverse
	#anim_player.play_backwards("fade_in")

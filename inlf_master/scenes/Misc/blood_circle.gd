extends Interactable

func _ready():
	anim_player.play("RESET")
	anim_player.seek(0, true)

func _interact(_actor):
	Globals.emit_signal("on_pop_notification", "I touch the blood circle, seeing the rot.")
	# for now, only spawn a dark altar
	# the buy menu for other things like tumors or plague batteries will be added when those are

func _on_Area_body_exited(body):
	if body == Globals.current_player:
		queue_free()

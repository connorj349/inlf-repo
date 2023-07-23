extends Interactable

var altar = preload("res://gameobjects/dark_altar.tscn")

# instead of spawning an altar, when the player consumes an organ while within the blood circle, create
# a spell effect using the player as the origin

func _ready():
	anim_player.play("RESET")
	anim_player.seek(0, true)
	# start a timer that will destroy this object after timeup instead of if player leaves circle

func _interact(_actor):
	Globals.emit_signal("on_pop_notification", "I touch the blood circle, seeing the rot.")
	queue_free() # remove the blood circle

func _on_Area_body_exited(body): # REMOVE
	if body == Globals.current_player:
		queue_free()

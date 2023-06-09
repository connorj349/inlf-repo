extends Interactable

func _ready():
	anim_player.play("RESET")
	anim_player.seek(0, true)

func _interact(_actor):
	Globals.emit_signal("on_pop_notification", "I touch the blood circle, seeing the rot.")

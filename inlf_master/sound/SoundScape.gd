extends Spatial

onready var sound_pool = $SoundPool

func _ready():
	pass # Replace with function body.

func _on_Area_body_entered(body):
	sound_pool.PlayRandomSound()

func _on_Area_body_exited(body):
	for audioplayer in sound_pool.get_children():
		audioplayer.stop()

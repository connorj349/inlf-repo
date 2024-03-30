extends Spatial

onready var sound_pool = $SoundPool

func _on_Area_body_entered(body):
	if body == Globals.current_player:
		sound_pool.PlayRandomSound()

func _on_Area_body_exited(body):
	if body == Globals.current_player:
		for sound_queue in sound_pool.get_children():
			for audio_player in sound_queue.get_children():
				audio_player.stop()

func _on_Timer_timeout():
	for body in $Area.get_overlapping_bodies():
		if body == Globals.current_player:
			if !soundscape_is_playing():
				sound_pool.PlayRandomSound()

func soundscape_is_playing():
	for audioplayer in sound_pool.get_children():
		if audioplayer.playing:
			return true
		else:
			return false

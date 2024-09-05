extends Area3D
## Soundscape
## depends on the type of audio stream player
## if it's a 3D, then the sound plays as the player nears and stops as the player leaves
## if its a screenspace player, then it continues to play

@export var audio_stream_player: Node # audio stream player 3D or regular
@export var collision_shape: CollisionShape3D
@export var fade_out_sound_animation_player: AnimationPlayer

func _ready():
	if !is_in_group("soundscapes"):
		add_to_group("soundscapes")

func _on_body_entered(_body):
	if audio_stream_player is AudioStreamPlayer:
		var soundscapes = get_tree().get_nodes_in_group("soundscapes")
		# exclude self to prevent this soundscape from turning itself off
		soundscapes.erase(self)
		
		for soundscape in soundscapes:
			if soundscape.audio_stream_player is AudioStreamPlayer and soundscape.audio_stream_player.playing:
				# fade out sound
				soundscape.fade_in_sound(false)
				
				await soundscape.fade_out_sound_animation_player.animation_finished
				
				soundscape.audio_stream_player.stop()
	
	if !audio_stream_player.playing:
		# fade in this soundscapes sound
		audio_stream_player.play()
		fade_in_sound(true)

# stop playing audio stream player if 3D
func _on_body_exited(_body):
	if audio_stream_player is AudioStreamPlayer3D:
		audio_stream_player.stop()
		fade_in_sound(false)

func fade_in_sound(fade_in: bool):
	if fade_in:
		fade_out_sound_animation_player.play("fade_in")
	else:
		fade_out_sound_animation_player.play_backwards("fade_in")

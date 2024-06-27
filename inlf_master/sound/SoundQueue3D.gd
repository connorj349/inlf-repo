@tool
extends Node3D
class_name SoundQueue3D

@export var Count: int = 1

var next = 0
var audio_stream_players: Array

func _ready():
	if get_child_count() == 0:
		print("No AudioStreamPlayer child found.")
		return

	var child = get_children()[0]
	if child is AudioStreamPlayer3D:
		audio_stream_players.append(child)
		
		for n in Count:
			var _duplicate = child.duplicate()
			add_child(_duplicate)
			audio_stream_players.append(_duplicate)

func PlaySound():
	if !audio_stream_players[next].playing:
		audio_stream_players[next].play()
		next += 1
		next %= audio_stream_players.size()

func PlaySoundRange(_min, _max):
	if !audio_stream_players[next].playing:
		audio_stream_players[next].pitch_scale = randf_range(_min, _max)
		audio_stream_players[next].play()
		next += 1
		next %= audio_stream_players.size()

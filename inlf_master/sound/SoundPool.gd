extends Spatial
class_name SoundPool # this class can only handle SoundQueue3D, not regular Soundqueues(screenspace)

var sounds: Array
var rng = RandomNumberGenerator.new()
var last_index

func _ready():
	for child in get_children():
		if child is SoundQueue3D:
			sounds.append(child)

func PlayRandomSound():
	var index
	while index == last_index:
		index = rng.randi_range(0, sounds.size() - 1)
	sounds[index].PlaySound()

func PlayRandomSoundRange(_min, _max):
	var index
	while index == last_index:
		index = rng.randi_range(0, sounds.size() - 1)
	sounds[index].PlaySoundRange(_min, _max)

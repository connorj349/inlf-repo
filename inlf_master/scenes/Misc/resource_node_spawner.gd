extends Spatial

export(PackedScene) var node_to_spawn
export(float) var spawn_frequency = 60

onready var timer = $Timer
onready var area = $Area
onready var spawn_sound = $spawn_noise

func _ready():
	timer.wait_time = spawn_frequency

func _on_Timer_timeout():
	if node_to_spawn: #only spawn if we have set the node to spawn an item
		for body in area.get_overlapping_bodies(): #if there is an object in the way, dont spawn
			if body is Interactable:
				return
		var new_spawn = node_to_spawn.instance()
		get_tree().get_root().add_child(new_spawn)
		new_spawn.global_transform = global_transform
		spawn_sound.play()
		# spawn a temporal portal effect

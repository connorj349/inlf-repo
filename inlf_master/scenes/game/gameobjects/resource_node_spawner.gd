extends Node3D

@export var node_to_spawn: PackedScene
@export var spawn_frequency: float = 60.0

@onready var timer = $Timer
@onready var area = $Area3D
@onready var spawn_sound = $spawn_noise

func _ready():
	if spawn_frequency <= 0: #if the spawn frequency is zero, don't use a timer(represents a 1-time spawn)
		timer.queue_free()
	else:
		timer.wait_time = spawn_frequency

func spawn():
	if node_to_spawn: #only spawn if we have set the node to spawn an item
		if area.get_overlapping_bodies().size() > 0:
			return
		var new_spawn = node_to_spawn.instantiate()
		get_tree().get_root().add_child(new_spawn)
		new_spawn.global_transform = global_transform
		spawn_sound.play()
		# spawn a temporal portal effect

func _on_Timer_timeout():
	Gamestate.request_spawn(self)
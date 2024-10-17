extends Node3D

@export var node_to_spawn: PackedScene
@export var spawn_frequency: float = 60.0
@export var apply_impulse_force = false # off normally by default

@onready var timer = $Timer
@onready var area = $Area3D
@onready var pos = global_position

func _ready():
	if spawn_frequency <= 0: #if the spawn frequency is zero, don't use a timer(represents a 1-time spawn)
		timer.queue_free()
	else:
		timer.wait_time = spawn_frequency

# the entire purpose of this is so that this respawner can detect staticbodies due to an engine bug :(
func _physics_process(_delta):
	global_position = pos + Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1)) * .001

# return the spawned object to modify/connect signals
func spawn():
	if node_to_spawn: #only spawn if we have set the node to spawn an item
		if area.get_overlapping_bodies().size() > 0:
			return
		
		var new_spawn = node_to_spawn.instantiate()
		get_tree().current_scene.game_world.add_child(new_spawn)
		new_spawn.global_transform = global_transform
		
		if apply_impulse_force:
			new_spawn.apply_impulse(Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 5)
		
		return new_spawn

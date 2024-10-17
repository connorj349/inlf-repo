extends Node3D

@export var npc_to_spawn: PackedScene
@export var timer: Timer
@export var max_npcs: int = 1

var spawned_npcs = []

@onready var resource_node_spawner: Node3D = $resource_node_spawner

func _ready():
	resource_node_spawner.node_to_spawn = npc_to_spawn
	timer.connect("timeout", Callable(self, "spawn_npc"))

func spawn_npc():
	if spawned_npcs.size() < max_npcs:
		var new_npc = resource_node_spawner.spawn()
		spawned_npcs.append(new_npc)
	
	# erase any non-valid entries
	for npc in spawned_npcs:
		if !is_instance_valid(npc):
			spawned_npcs.erase(npc)

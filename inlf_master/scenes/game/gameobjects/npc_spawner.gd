extends Node3D

@export var npc_to_spawn: PackedScene
@export var timer: Timer
@export var max_npcs: int = 1

@onready var resource_node_spawner: Node3D = $resource_node_spawner

func _ready():
	resource_node_spawner.node_to_spawn = npc_to_spawn
	timer.connect("timeout", Callable(self, "spawn_npc"))

func spawn_npc():
	if get_tree().get_nodes_in_group("npc").size() < max_npcs:
		resource_node_spawner.spawn()

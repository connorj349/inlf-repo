extends Node3D

@export var rot_object_to_spawn: PackedScene
# 0 - 1.0, represents the percentage of total rot this spawner begins spawning
@export var rot_percentage_to_spawn_on: float = 0.1
@export var spawn_timer: Timer

@onready var resource_node_spawner: Node3D = $resource_node_spawner

func _ready():
	resource_node_spawner.node_to_spawn = rot_object_to_spawn
	spawn_timer.connect("timeout", Callable(self, "check_rot"))

func check_rot():
	#if get_tree().current_scene.game_world.current_level.rot
	if float(Gamestate.rot) / float(Globals.rot_max_value) >= rot_percentage_to_spawn_on:
		resource_node_spawner.spawn()

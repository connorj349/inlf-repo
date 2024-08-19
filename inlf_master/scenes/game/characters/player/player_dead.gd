extends Node3D

@export var mouse_sensitivity = 0.1
@export var player_ghost_prefab: PackedScene
@export var outer_gimbal: Node3D
@export var inner_gimbal: Node3D
@export var death_sound: AudioStreamPlayer

func _input(event):
	if event is InputEventMouseMotion:
		outer_gimbal.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		inner_gimbal.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		inner_gimbal.rotation.x = clamp(inner_gimbal.rotation.x, deg_to_rad(-89), deg_to_rad(0))

func play_death_sound():
	death_sound.play()

func _on_PlayerSpawnTimer_timeout():
	var ghost = player_ghost_prefab.instantiate()
	get_tree().current_scene.game_world.add_child(ghost)
	ghost.global_transform = global_transform
	
	queue_free()

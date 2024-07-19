extends Node3D

@export var mouse_sensitivity = 0.1
@export var player_ghost_prefab: PackedScene

@onready var outer_gimbal = $OuterGimbal
@onready var inner_gimbal = $OuterGimbal/InnerGimbal
@onready var death = $Death

func _ready():
	$Movement.init(self)

func _input(event):
	if event is InputEventMouseMotion:
		outer_gimbal.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		inner_gimbal.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		inner_gimbal.rotation.x = clamp(inner_gimbal.rotation.x, deg_to_rad(-89), deg_to_rad(0))

func play_death_sound():
	death.play()

func _on_PlayerSpawnTimer_timeout():
	var ghost = player_ghost_prefab.instantiate()
	get_tree().get_root().add_child(ghost)
	ghost.global_transform = global_transform
	queue_free()

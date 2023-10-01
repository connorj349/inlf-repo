extends Spatial

export var mouse_sensitivity = 0.1

onready var outer_gimbal = $OuterGimbal
onready var inner_gimbal = $OuterGimbal/InnerGimbal
onready var death = $Death

var player_ghost_prefab = preload("res://Characters/Player/Player_Ghost.tscn")

func _ready():
	$Movement.init(self)

func _input(event):
	if event is InputEventMouseMotion:
		outer_gimbal.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		inner_gimbal.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		inner_gimbal.rotation.x = clamp(inner_gimbal.rotation.x, deg2rad(-89), deg2rad(0))

func play_death_sound():
	# play generic death sound from SoundManager
	death.play()

func _on_PlayerSpawnTimer_timeout():
	var ghost = player_ghost_prefab.instance()
	get_tree().get_root().add_child(ghost)
	ghost.global_transform = global_transform
	queue_free()

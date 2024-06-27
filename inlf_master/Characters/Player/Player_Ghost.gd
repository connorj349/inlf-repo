extends CharacterBody3D

@export var possible_noises: Array[AudioStream]
@export var mouse_sensitivity = 0.1
@export var speed = 15
@export var accel = 7

@onready var head = $Head
@onready var noises = $SoundPool

var movement : Vector3

func _ready():
	add_to_group("Ghost")

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	var direction = Vector3.ZERO
	#movement capture
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input)
	direction = direction.normalized()
	#move in facing direction
	var hrot = global_transform.basis.get_euler().y
	direction = direction.rotated(Vector3.UP, hrot)
	if Input.is_action_pressed("jump"):
		direction.y += 1
	if Input.is_action_pressed("descend"):
		direction.y -= 1
	velocity = velocity.lerp(direction * speed, accel * delta)
# warning-ignore:return_value_discarded
	set_velocity(velocity)
	move_and_slide()


func _on_Timer_timeout():
	noises.PlayRandomSound()

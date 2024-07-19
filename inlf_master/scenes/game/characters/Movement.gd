extends Node3D

enum State {
	NORMAL,
	LADDER
}

const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1

@export var speed = 15
@export var gravity = 30
@export var jump_power = 10
@export var ignore_rotation = false #used by npcs for correct movement

# footstep public vars
@export var footstep_freq = 25 # how often to make footsteps happen

@onready var accel = ACCEL_DEFAULT

# footstep vars
@onready var step_stone = $step_stone_SoundPool
@onready var step_transition = $step_transition_SoundPool
@onready var step_mud = $step_mud_SoundPool
@onready var ground_raycast = $GroundRayCast

var body : CharacterBody3D = null
var snap
var frozen = false
var is_jumping = false

var direction = Vector3()
var velocity = Vector3()
var gravity_direction = Vector3()
var movement = Vector3()

# time since last footstep
var footstep_time = 0

#ladder
var ladder_array = []
var current_state = State.NORMAL

func init(_body : CharacterBody3D):
	body = _body

func _process(_delta): # calculate footsteps
	if body.is_on_floor() and direction.length() > 0: #footstep calculating
			footstep_time += direction.length()
			if footstep_time >= footstep_freq:
				footstep_time = 0
				footstep()

func _physics_process(delta):
	if frozen:
		return
	var cur_dir = direction
	var hrot = global_transform.basis.get_euler().y
	if !ignore_rotation:
		cur_dir = cur_dir.rotated(Vector3.UP, hrot)
	if body.is_on_floor():
		snap = -body.get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_direction = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_direction += Vector3.DOWN * gravity * delta
	if current_state == State.LADDER:
		gravity_direction = Vector3.ZERO
		snap = Vector3.ZERO
		accel = 20
	if is_jumping:
		snap = Vector3.ZERO
		gravity_direction = Vector3.UP * jump_power
	is_jumping = false
	velocity = velocity.lerp(cur_dir * speed, accel * delta)
	movement = velocity + gravity_direction
# warning-ignore:return_value_discarded
	body.set_velocity(movement)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
	body.set_up_direction(Vector3.UP)
	body.move_and_slide()

func set_move_vector(_move_vec : Vector3):
	if current_state == State.LADDER:
		direction = Vector3(_move_vec.x, _move_vec.z * -1, 0).normalized()
	else:
		direction = _move_vec.normalized()

func jump():
	current_state = State.NORMAL
	is_jumping = true

func footstep(): #check the tile, play the sound, all timing is done in _process
	var coll_tileset = ground_raycast.get_collider()
	if ground_raycast.is_colliding():
		if coll_tileset.is_in_group("ground_stone"):
			step_stone.PlayRandomSoundRange(0.7, 1.3)
		elif coll_tileset.is_in_group("ground_transition"):
			step_transition.PlayRandomSoundRange(0.7, 1.3)
		elif coll_tileset.is_in_group("ground_mud"):
			step_mud.PlayRandomSoundRange(0.7, 1.3)

func freeze():
	frozen = true

func unfreeze():
	frozen = false

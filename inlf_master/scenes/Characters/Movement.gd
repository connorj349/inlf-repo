extends Spatial

export var speed = 15
export var gravity = 30
export var jump_power = 10
export var ignore_rotation = false #used by npcs for correct movement

const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1

onready var accel = ACCEL_DEFAULT

var body : KinematicBody = null
var snap
var frozen = false
var is_jumping = false

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

func init(_body : KinematicBody):
	body = _body

func set_move_vector(_move_vec : Vector3):
	direction = _move_vec.normalized()

func jump():
	is_jumping = true

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
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	if is_jumping:
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump_power
	is_jumping = false
	velocity = velocity.linear_interpolate(cur_dir * speed, accel * delta)
	movement = velocity + gravity_vec
# warning-ignore:return_value_discarded
	body.move_and_slide_with_snap(movement, snap, Vector3.UP)

func freeze():
	frozen = true

func unfreeze():
	frozen = false

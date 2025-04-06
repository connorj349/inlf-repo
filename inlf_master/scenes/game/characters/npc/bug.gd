extends CharacterBody3D

const SPEED: float = 2.5

@export var hit_effect: PackedScene

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var change_direction_interval: float = 2.0
var direction: Vector3 = Vector3.ZERO
var time_since_last_direction_change: float = 0.0
var target: Node3D
var time_spent_chasing: float = 0.0
var time_since_last_attacked: float = 0.0
var is_attacking = false
var dead = false

@onready var health = $Health
@onready var hurt_sound: SoundQueue3D = $HurtSound
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer

func _ready():
	health.init()
	health.connect("dead", Callable(func():
		queue_free()))
	animation_player.connect("animation_finished", Callable(func(anim_name):
		if anim_name == "Attack":
			is_attacking = false))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if !dead:
		if is_instance_valid(target):
			_chase_target(delta)
		else:
			time_since_last_direction_change += delta
			
			if time_since_last_direction_change >= change_direction_interval:
				_change_random_direction()
				time_since_last_direction_change = 0.0
			
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		
		var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
		if horizontal_velocity.length_squared() > 0.01:
			look_at(global_position + horizontal_velocity.normalized(), Vector3.UP)
			rotate_object_local(Vector3.UP, PI)
		
		if !dead and !is_attacking and velocity.length_squared() > 0.01:
			if not animation_player.is_playing() or animation_player.current_animation != "Walk":
				animation_player.play("Walk")
		
		move_and_slide()

func on_hurt(_damage):
	if dead:
		return
	
	var new_effect = hit_effect.instantiate()
	get_tree().current_scene.game_world.add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	
	hurt_sound.PlaySoundRange(0.8, 1.2)
	
	health.health -= _damage.amount

func _chase_target(delta: float):
	var chase_time: float = 10.0
	time_spent_chasing += delta
	
	_attack_target(delta)
	
	if time_spent_chasing >= chase_time and time_since_last_attacked > 10.0:
		target = null
		time_spent_chasing = 0.0
	
	if is_instance_valid(target):
		var target_direction = (target.global_position - global_position).normalized()
		
		velocity.x = target_direction.x * SPEED
		velocity.z = target_direction.z * SPEED

func _attack_target(delta: float):
	var distance_to_target = global_position.distance_to(target.global_position)
	time_since_last_attacked += delta
	
	if time_since_last_attacked >= 1.0 and distance_to_target <= 2.0:
		if is_instance_valid(target):
			target.health.pox += 1
		
		is_attacking = true
		animation_player.play("Attack")
		time_since_last_attacked = 0.0

func _change_random_direction():
	if randf() < 0.3:
		direction = Vector3.ZERO
	else:
		var random_angle_y = randf() * TAU
		direction = Vector3(sin(random_angle_y), 0, cos(random_angle_y)).normalized()
	
	if direction == Vector3.ZERO:
		animation_player.play("Idle")
	else:
		animation_player.play("Walk")

func _on_detect_enemies_area_body_entered(body):
	target = body

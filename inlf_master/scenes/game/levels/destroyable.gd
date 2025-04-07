extends HintObject

@export var health: Node3D
@export var hurt_sound: AudioStreamPlayer3D
@export var death_sound: AudioStreamPlayer3D
@export var destroy_object: Node3D

var dead = false

func _ready():
	health.init()
	health.connect("dead", Callable(func():
		death_sound.play()
		visible = false
		
		await death_sound.finished
		
		if destroy_object:
			destroy_object.queue_free()
		else:
			queue_free()))

func on_hurt(damage: Damage):
	if !dead:
		health.health -= damage.amount
		hurt_sound.play()
		
		if health.health <= 0:
			dead = true

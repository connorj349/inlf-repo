extends Node3D

@export var effect: PackedScene
@export var area: Area3D

var dead = false

@onready var pop_sound: AudioStreamPlayer3D = $PopSound

@warning_ignore("unused_parameter")
func _on_Area_body_entered(body):
	if body.has_method("on_hurt"):
		body.health.pox += 3
	
	disturb()

# not going to bother calculating health on this object
func on_hurt(_damage: Damage):
	if !dead:
		disturb()

func disturb():
	dead = true
	
	$DisturbedAnimations.play("jiggle")
	
	create_effect()
	
	area.set_deferred("monitoring", false)

func create_effect():
	var new_effect = effect.instantiate()
	get_tree().current_scene.game_world.add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	
	pop_sound.play()
	
	# spawn popping effect
	
	await get_tree().create_timer(5.0).timeout
	
	queue_free()

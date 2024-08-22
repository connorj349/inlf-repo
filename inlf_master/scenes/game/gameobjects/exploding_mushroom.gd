extends Node3D

@export var effect: PackedScene
@export var area: Area3D

@onready var pop_sound: AudioStreamPlayer3D = $PopSound

@warning_ignore("unused_parameter")
func _on_Area_body_entered(body):
	explode()

# not going to bother calculating health on this object
func on_hurt(_damage: Damage):
	explode()

func explode():
	var new_effect = effect.instantiate()
	get_tree().current_scene.game_world.add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	pop_sound.play()
	visible = false
	# spawn popping effect
	await pop_sound.finished
	queue_free()

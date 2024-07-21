extends Node3D

@export var effect: PackedScene
@export var area: Area3D

@warning_ignore("unused_parameter")
func _on_Area_body_entered(body):
	var new_effect = effect.instantiate()
	get_tree().get_root().add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	queue_free()

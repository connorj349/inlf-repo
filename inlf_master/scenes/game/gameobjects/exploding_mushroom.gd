extends Node3D

@export var effect: PackedScene

@onready var area = $Area3D

func _on_Area_body_entered(body):
	if body == Globals.current_player:
		var new_effect = effect.instantiate()
		get_tree().get_root().add_child(new_effect)
		new_effect.global_transform.origin = global_transform.origin
		queue_free()

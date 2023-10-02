extends Spatial

onready var area = $Area

var bloater = preload("res://gameobjects/bloater.tscn")

func _on_Area_body_entered(body):
	if body.is_in_group("corpse"):
		var new_bloater = bloater.instance()
		get_tree().get_root().add_child(new_bloater)
		new_bloater.global_transform.origin = self.global_transform.origin
		body.queue_free() # delete corpse

func _on_Timer_timeout():
	$cloud.emitting = false
	$drips.emitting = false
	while $cloud.emitting:
		yield()
	queue_free() # delete this spell effect

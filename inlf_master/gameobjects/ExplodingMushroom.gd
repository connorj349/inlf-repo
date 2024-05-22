extends Spatial

const effect = preload("res://effects/spell effects/spell_effect_viletouch.tscn")

onready var area = $Area

func _on_Area_body_entered(body):
	if body == Globals.current_player:
		var new_effect = effect.instance()
		get_tree().get_root().add_child(new_effect)
		new_effect.global_transform.origin = global_transform.origin
		queue_free()

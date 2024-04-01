extends KinematicBody

const MOVE_SPEED = 3
const effect = preload("res://Characters/enemies/shadow/ShadowEmergenceEffect.tscn")

onready var raycast = $RayCast

var player = null

func _ready():
	if Globals.current_player == null:
		return
	player = Globals.current_player

func _physics_process(delta):
	if player == null:
		return
	if !is_instance_valid(player):
		return
	
	var vec_to_player = player.translation - translation
	vec_to_player = vec_to_player.normalized()
	raycast.cast_to = vec_to_player * 1.5
	
# warning-ignore:return_value_discarded
	move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll == Globals.current_player:
			player = null
			coll.kill()

func _on_DespawnTimer_timeout():
	var new_effect = effect.instance()
	get_tree().get_root().add_child(new_effect)
	new_effect.global_transform.origin = global_transform.origin
	queue_free()

func _on_CheckForPlayerTimer_timeout():
	if player == null or !is_instance_valid(player):
		player = Globals.current_player

extends Spatial

onready var area = $Area

func _on_Area_body_entered(body):
	if body == Globals.current_player:
		body.health.pox += 5

func _on_Timer_timeout():
	$cloud.emitting = false
	$drips.emitting = false
	while $cloud.emitting:
		yield()
	queue_free()

func _on_TickTimer_timeout():
	for body in area.get_overlapping_bodies():
		if body == Globals.current_player:
			Globals.current_player.health.pox += 2

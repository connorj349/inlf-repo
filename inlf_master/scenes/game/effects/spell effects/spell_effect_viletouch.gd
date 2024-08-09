extends Node3D

@export var area: Area3D

func _on_Timer_timeout():
	$cloud.emitting = false
	$drips.emitting = false
	
	await $cloud.finished
	
	queue_free()

func _on_TickTimer_timeout():
	for body in area.get_overlapping_bodies():
		Globals.current_player.health.pox += 2
		return

extends Node3D

@export var area: Area3D

@onready var gestating_sound = $GestatingSound

func _ready():
	gestating_sound.play()

func _on_Timer_timeout():
	$cloud.emitting = false
	$drips.emitting = false
	gestating_sound.stop()
	
	await $cloud.finished
	
	queue_free()

func _on_TickTimer_timeout():
	for body in area.get_overlapping_bodies():
		body.health.pox += 2
		return

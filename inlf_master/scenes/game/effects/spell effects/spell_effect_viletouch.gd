extends Node3D

@export var area: Area3D

@onready var gestating_sound = $GestatingSound
@onready var clouds = $cloud
@onready var drips = $drips

func _ready():
	gestating_sound.play()

func _on_Timer_timeout():
	$cloud.emitting = false
	$drips.emitting = false
	gestating_sound.stop()
	
	await get_tree().create_timer(1.0).timeout
	
	queue_free()

func _on_TickTimer_timeout():
	for body in area.get_overlapping_bodies():
		body.health.pox += 2
		return

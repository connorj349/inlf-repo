extends Node3D

func _ready():
	$Particles.emitting = true

func _on_particles_finished():
	queue_free()

func _on_detect_altar_area_body_entered(body):
	if body.has_method("begin_ritual"):
		#if body.begin_ritual: spawn additional particles to let us know it was successful?
		body.begin_ritual()

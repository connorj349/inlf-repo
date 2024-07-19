extends Area3D

signal submerged_status_changed

var submerged = false: set = set_submerged

func set_submerged(value):
	submerged = value
	emit_signal("submerged_status_changed")

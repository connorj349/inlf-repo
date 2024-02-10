extends Area

var submerged = false setget set_submerged

signal submerged_status_changed

func set_submerged(value):
	submerged = value
	emit_signal("submerged_status_changed")

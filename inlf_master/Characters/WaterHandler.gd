extends Area

signal submerged_status_changed

var submerged = false setget set_submerged

func set_submerged(value):
	submerged = value
	emit_signal("submerged_status_changed")

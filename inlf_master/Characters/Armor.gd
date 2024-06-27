extends Node3D

signal armor_changed

@export var max_armor: int = 1
@export var start_with_armor: bool = false

var armor : set = set_armor

func init():
	if start_with_armor:
		armor = max_armor
		return
	armor = 0

func set_armor(val):
	armor = clamp(val, 0, max_armor)
	emit_signal("armor_changed", armor)

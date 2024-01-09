extends Spatial

export(int) var max_armor = 1
export(bool) var start_with_armor = false

var armor setget set_armor

func set_armor(val):
	armor = clamp(val, 0, max_armor)
	emit_signal("armor_changed")

signal armor_changed

func init():
	if start_with_armor:
		armor = max_armor
		return
	armor = 0

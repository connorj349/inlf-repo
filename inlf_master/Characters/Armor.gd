extends Spatial

export(int) var max_armor = 1
export(bool) var start_with_armor = false

var armor

signal armor_changed
signal damage_dealt

func init():
	if start_with_armor:
		armor = max_armor
	armor = 0
	emit_signal("armor_changed", armor)

func calc_damage(amount):
	armor = clamp(armor + amount, 0, max_armor)
	emit_signal("armor_changed", armor)
	if armor <= 0:
		emit_signal("damage_dealt", amount)

func add_armor(amount):
	armor = clamp(armor + amount, 0, max_armor)
	emit_signal("armor_changed", armor)

extends Node
## REMOVE THIS SCRIPT
## 
## going to use a different level loading system so that this information is only contained]
## within an individual level instead of in an autoload to prevent confusion/errors

signal rot_changed
signal bones_changed
signal infections_count_changed

# each of these should be created at runtime instead of referenced like this
# player's inventory
var player_inventory = load("res://scenes/game/inventory/player_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = load("res://scenes/game/inventory/player_equipment_inventory.tres")
# player's weapon slot
var weapon_player_inventory = load("res://scenes/game/inventory/player_weapon_inventory.tres")

var rot: int = 0 :
	set(value):
		rot = clamp(value, 0, Globals.rot_max_value)
		if rot >= Globals.rot_max_value:
			emit_signal("game_over")
		emit_signal("rot_changed")

# reduce below to 0 when done testing
var bones: int = 100 :
	set(value):
		bones = clamp(value, 0, 9999)
		emit_signal("bones_changed", bones)
		if value > 0:
			Globals.emit_signal("on_pop_notification", "I received some bones.")
		elif value < 0:
			Globals.emit_signal("on_pop_notification", "I have lost some bones.")

var bloaters: int = 0 :
	set(value):
		bloaters = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var tumors: int = 0 :
	set(value):
		tumors = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var infections: int :
	get:
		return bloaters + tumors

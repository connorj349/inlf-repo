extends Node

# player's inventory
var player_inventory = preload("res://inventory/player_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = preload("res://inventory/player_equipment_inventory.tres")
# player's weapon slot
var weapon_player_inventory = preload("res://inventory/player_weapon_inventory.tres")
# global merchant inventory for all vendors to reference
var merchant_inventory = preload("res://inventory/merchant_inventory.tres")

signal rot_changed
signal on_rot_reached_max
signal bones_changed
# warning-ignore:unused_signal
signal on_player_death
# warning-ignore:unused_signal
signal on_player_spawn
# warning-ignore:unused_signal
signal on_stem_cells_changed
signal infections_count_changed

var rot = 0 setget set_rot
var bones = 0 setget set_bones
var bloaters = 0 setget set_bloaters
var tumors = 0 setget set_tumors
var infections setget , get_infections

func reset_player_equipment():
	equip_player_inventory.take_item(Gamestate.equip_player_inventory.slot_datas[0])
	weapon_player_inventory.take_item(Gamestate.weapon_player_inventory.slot_datas[0])

func reset_player_inventory():
	for item in player_inventory.slot_datas.size():
		if player_inventory.slot_datas[item]:
			player_inventory.take_item(player_inventory.slot_datas[item])

func set_rot(value):
	rot = clamp(value, 0, Globals.rot_max_value)
	if rot >= Globals.rot_max_value:
		emit_signal("on_rot_reached_max")
		return
	emit_signal("rot_changed")

func set_bones(value):
	bones = clamp(value, 0, 9999)
	emit_signal("bones_changed", bones)
	if value > 0:
		Globals.emit_signal("on_pop_notification", "I received %s bones." % value)
	elif value < 0:
		Globals.emit_signal("on_pop_notification", "I have lost %s bones." % value)

func set_bloaters(value):
	bloaters = clamp(value, 0, 9999)
	emit_signal("infections_count_changed")

func set_tumors(value):
	tumors = clamp(value, 0, 9999)
	emit_signal("infections_count_changed")

func get_infections():
	return bloaters + tumors

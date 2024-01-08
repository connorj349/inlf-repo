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

var rot = 0 # world rot count
var bones = 0 # player money

func reset_player_equipment():
	equip_player_inventory.take_item(Gamestate.equip_player_inventory.slot_datas[0])
	weapon_player_inventory.take_item(Gamestate.weapon_player_inventory.slot_datas[0])

func reset_player_inventory():
	for item in player_inventory.slot_datas.size():
		if player_inventory.slot_datas[item]:
			player_inventory.take_item(player_inventory.slot_datas[item])

func rot_modify(amount):
	rot = clamp(rot + amount, 0, Globals.rot_max_value)
	emit_signal("rot_changed")
	if rot >= Globals.rot_max_value:
		emit_signal("on_rot_reached_max")

func can_afford(amount):
	return bones >= amount

func bones_updated(amount):
	if amount < 0:
		Globals.emit_signal("on_pop_notification", "I have lost %s bones." % amount)
	else:
		Globals.emit_signal("on_pop_notification", "I received %s bones." % amount)
	bones = clamp(bones + amount, 0, 9999)
	emit_signal("bones_changed")

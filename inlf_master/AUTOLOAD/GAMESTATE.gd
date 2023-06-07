extends Node

# need to finish the 'end game' when rot reaches 100

# player's inventory
var player_inventory = preload("res://inventory/player_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = preload("res://inventory/player_equipment_inventory.tres")
# player's weapon slot
var weapon_player_inventory = preload("res://inventory/player_weapon_inventory.tres")
# global merchant inventory for all vendors to reference
var merchant_inventory = preload("res://inventory/merchant_inventory.tres")

signal rot_changed
signal bones_changed

var rot = 0 #world rot percentage
var bones = 0 #player money

func rot_modify(amount):
	rot = clamp(rot + amount, 0, 100)
	emit_signal("rot_changed")
	if rot >= 100:
		#change scene to end of game cutscene; this scene will show restart button
		pass

func can_afford(amount):
	return bones >= amount

func bones_updated(amount):
	bones = clamp(bones + amount, 0, 9999)
	emit_signal("bones_changed")

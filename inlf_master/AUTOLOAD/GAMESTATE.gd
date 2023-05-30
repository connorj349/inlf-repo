extends Node

# need to finish the 'end game' when rot reaches 100

# player's iventory
var player_inventory = preload("res://inventory/test_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = preload("res://inventory/player_equipment_inventory.tres")
# global merchant inventory for all vendors to reference
var merchant_inventory = preload("res://inventory/merchant_inventory.tres")

signal rot_changed

var rot = 0 #world rot percentage

func rot_modify(amount):
	rot = clamp(rot + amount, 0, 100)
	emit_signal("rot_changed")
	if rot >= 100:
		#change scene to end of game cutscene; this scene will show restart button
		pass

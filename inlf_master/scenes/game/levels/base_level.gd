extends Node3D
class_name Level
## place this script in the uppermost part of a level's hierarchy
## extend this script to include win/loss conditions of certain levels
##
## win conditions:
##		using the ticket machine to escape the city
##
## lose condition:
##		losing the last stem cell

signal goto_main

const pickup = preload("res://scenes/game/item/pick_up/pickup.tscn")
const corpse = preload("res://scenes/game/characters/corpse.tscn")

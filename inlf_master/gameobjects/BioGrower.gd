extends Interactable

# horizontal bars
onready var blood_prog_bar = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/BloodProgressBar
onready var water_prog_bar = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/WaterProgressBar
onready var fertilizer_prog_bar = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/FertilizerProgressBar
onready var exotic_prog_bar = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/ExoticProgressBar

#vertical bar
onready var growth_prog_bar = $CanvasLayer/Control/VBoxContainer/HBoxContainer/GrowthProgressBar

onready var spawn_point = $SpawnPoint

onready var resource_consume_timer = $ResourceConsumeTimer

var blood setget set_blood
var water setget set_water
var fertilizer setget set_fertilizer
var exotic setget set_exotic
var growth setget set_growth

var current_growing_seed_item_data

func _ready():
	self.blood = 0
	self.water = 0
	self.fertilizer = 0
	self.exotic = 0
	self.growth = 0
	blood_prog_bar.init(0, 100)
	water_prog_bar.init(0, 100)
	fertilizer_prog_bar.init(0, 100)
	exotic_prog_bar.init(0, 100)

func _interact(_actor):
	# hurt the player
	# Globals.current_player.hurt()
	self.blood += 10

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if body.slot_data.item_data is ItemDataSeed:
			current_growing_seed_item_data = body.slot_data.item_data
			$GrowTimer.start()
			resource_consume_timer.start()
			body.queue_free()
			return
		match(body.slot_data.item_data.item_type):
			ItemData.ItemType.Fertilizer:
				self.fertilizer += 10
				body.queue_free()
			ItemData.ItemType.Water:
				self.water += 10
				body.queue_free()
			ItemData.ItemType.Exotic:
				self.exotic += 10
				body.queue_free()

func _on_GrowTimer_timeout():
	if growth > current_growing_seed_item_data.growth_needed:
		for item_data in current_growing_seed_item_data.output_item_data:
			var new_slot = SlotData.new()
			new_slot.item_data = item_data
			Globals.create_pickup(new_slot, spawn_point)
	else:
		pass
		# create explosion
	resource_consume_timer.stop()
	current_growing_seed_item_data = null
	self.growth = 0

func _on_ResourceConsumeTimer_timeout():
	if blood >= current_growing_seed_item_data.blood:
		self.blood -= current_growing_seed_item_data.blood
		self.growth += 1
	else:
		self.growth -= 1
	if water >= current_growing_seed_item_data.water:
		self.water -= current_growing_seed_item_data.water
		self.growth += 1
	else:
		self.growth -= 1
	if fertilizer >= current_growing_seed_item_data.fertilizer:
		self.fertilizer -= current_growing_seed_item_data.fertilizer
		self.growth += 1
	else:
		self.growth -= 1
	if exotic >= current_growing_seed_item_data.exotic:
		self.exotic -= current_growing_seed_item_data.exotic
		self.growth += 1
	else:
		self.growth -= 1

func set_blood(value):
	blood = clamp(value, 0, 100)
	blood_prog_bar.update_bar(blood)

func set_water(value):
	water = clamp(value, 0, 100)
	water_prog_bar.update_bar(water)

func set_fertilizer(value):
	fertilizer = clamp(value, 0, 100)
	fertilizer_prog_bar.update_bar(fertilizer)

func set_exotic(value):
	exotic = clamp(value, 0, 100)
	exotic_prog_bar.update_bar(exotic)

func set_growth(value):
	growth = clamp(value, 0, 100)
	growth_prog_bar.update_bar(growth)

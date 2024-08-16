extends Interactable

@export var blood_prog_bar: ProgressBar
@export var water_prog_bar: ProgressBar
@export var fertilizer_prog_bar: ProgressBar
@export var exotic_prog_bar: ProgressBar
@export var growth_prog_bar: ProgressBar
@export var player_use_damage: Damage

var blood :
	set(value):
		blood = clamp(value, 0, 100)
		blood_prog_bar.update_bar(blood)

var water :
	set(value):
		water = clamp(value, 0, 100)
		water_prog_bar.update_bar(water)

var fertilizer :
	set(value):
		fertilizer = clamp(value, 0, 100)
		fertilizer_prog_bar.update_bar(fertilizer)

var exotic :
	set(value):
		exotic = clamp(value, 0, 100)
		exotic_prog_bar.update_bar(exotic)

var growth :
	set(value):
		growth = clamp(value, 0, 100)
		growth_prog_bar.update_bar(growth)

var current_growing_seed_item_data = null

@onready var spawn_point = $SpawnPoint
@onready var resource_consume_timer = $ResourceConsumeTimer
@onready var deposit_sound = $DepositSound
@onready var growth_timeout_sound: AudioStreamPlayer3D = $GrowthTimeoutSound
@onready var growth_timeout_fail_sound: AudioStreamPlayer3D = $GrowthTimeoutFailSound
@onready var growing_sound: AudioStreamPlayer3D = $GrowingSound

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

func _interact(actor):
	actor.on_hurt(player_use_damage)
	self.blood += player_use_damage.amount

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if body.slot_data.item_data is ItemDataSeed:
			current_growing_seed_item_data = body.slot_data.item_data
			
			# begin growth timer that, when ended, will produce finished good or explode
			$GrowTimer.start()
			
			# begin timer that consumes resources based on seed item_data
			resource_consume_timer.start()
			
			# remove the pickup
			body.queue_free()
			
			deposit_sound.play()
			# looping sound
			growing_sound.play(0)
			return
		match(body.slot_data.item_data.item_type):
			ItemData.ItemType.Fertilizer:
				for i in body.slot_data.quantity:
					self.fertilizer += 10
				body.queue_free()
			ItemData.ItemType.Water:
				for i in body.slot_data.quantity:
					self.water += 10
				body.queue_free()
			ItemData.ItemType.Exotic:
				for i in body.slot_data.quantity:
					self.exotic += 10
				body.queue_free()

func _on_GrowTimer_timeout():
	if growth >= current_growing_seed_item_data.growth_needed:
		for item_data in current_growing_seed_item_data.output_item_data:
			var new_slot = SlotData.new()
			new_slot.item_data = item_data
			
			var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
			new_pickup.global_transform.origin = $SpawnPoint.global_transform.origin
			get_tree().current_scene.game_world.add_child(new_pickup)
			
			growth_timeout_sound.play()
	else:
		growth_timeout_fail_sound.play()
		# create explosion
	
	resource_consume_timer.stop()
	current_growing_seed_item_data = null
	self.growth = 0
	growing_sound.stop()

func _on_ResourceConsumeTimer_timeout(): # also counts the vars that are not needed to increase growth like exotic
	if blood >= current_growing_seed_item_data.blood:
		self.blood -= current_growing_seed_item_data.blood
		self.growth += 1
	else:
		self.growth -= 2
	if water >= current_growing_seed_item_data.water:
		self.water -= current_growing_seed_item_data.water
		self.growth += 1
	else:
		self.growth -= 2
	if fertilizer >= current_growing_seed_item_data.fertilizer:
		self.fertilizer -= current_growing_seed_item_data.fertilizer
		self.growth += 1
	else:
		self.growth -= 2
	if exotic >= current_growing_seed_item_data.exotic:
		self.exotic -= current_growing_seed_item_data.exotic
		self.growth += 1
	else:
		self.growth -= 2

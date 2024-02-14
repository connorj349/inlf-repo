extends HintObject

export(Resource) var accepted_biomass_item_data
export(Array, Resource) var dropped_seeds
export(Resource) var slime_item_data

onready var hydration_prog_bar = $CanvasLayer/Control/VBoxContainer/HydrationProgressBar
onready var bio_prog_bar = $CanvasLayer/Control/VBoxContainer/BioProgressBar
onready var timer = $HydrationTimer

onready var water_handler = $WaterHandler

var current_biomass = 0 setget set_current_biomass

var rng = RandomNumberGenerator.new()

func _ready():
	hydration_prog_bar.init(0, timer.wait_time)
	bio_prog_bar.init(0, 10)
	timer.paused = true
	randomize()

func _process(_delta):
	if timer.time_left > 0:
		hydration_prog_bar.update_bar(timer.wait_time - timer.time_left)

func _on_ItemDeposit_body_entered(body):
	if current_biomass >= 10:
		return
	if body.is_in_group("pickup"):
		if accepted_biomass_item_data and body.slot_data.item_data == accepted_biomass_item_data:
			for n in body.slot_data.quantity:
				self.current_biomass += 2
			body.queue_free()

func _on_HydrationTimer_timeout():
	if current_biomass >= 10:
		if dropped_seeds.size() > 0:
			for i in 3:
				var random_index = rng.randi_range(0, dropped_seeds.size() - 1)
				var new_slot = SlotData.new()
				new_slot.item_data = dropped_seeds[random_index]
				Globals.create_pickup(new_slot, self)
			queue_free()
		return
	var new_slot = SlotData.new()
	new_slot.item_data = slime_item_data
	Globals.create_pickup(new_slot, self)
	queue_free()

func _on_WaterHandler_submerged_status_changed():
	timer.paused = !water_handler.submerged

func set_current_biomass(value):
	current_biomass = clamp(value, 0, 10)
	bio_prog_bar.update_bar(current_biomass)

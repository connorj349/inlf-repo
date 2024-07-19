extends HintObject

@export var fertilizer_item_data: ItemData

@onready var biomass_prog_bar = $CanvasLayer/Control/VBoxContainer/ProgressBar
@onready var production_prog_bar = $CanvasLayer/Control/VBoxContainer/ProductionProgressBar
@onready var timer = $CreateFertilizerTimer

var biomass : set = set_biomass

func _ready():
	self.biomass = 0
	biomass_prog_bar.init(0, 100)
	production_prog_bar.init(0, timer.wait_time)

func _process(_delta):
	if timer.time_left > 0:
		production_prog_bar.update_bar(timer.time_left)

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if body.slot_data.item_data.item_type == ItemData.ItemType.Biomass:
			body.queue_free()
			for i in body.slot_data.quantity:
				self.biomass += 2
			if biomass >= 10:
				timer.start()

func _on_CreateFertilizerTimer_timeout():
	if biomass >= 10:
		var new_slot_data = SlotData.new()
		new_slot_data.item_data = fertilizer_item_data
		Globals.create_pickup(new_slot_data, $ItemSpawnPoint)
		self.biomass -= 10
		if biomass < 10:
			timer.stop()
	else:
		timer.stop()

func set_biomass(value):
	biomass = clamp(value, 0, 100)
	biomass_prog_bar.update_bar(biomass)

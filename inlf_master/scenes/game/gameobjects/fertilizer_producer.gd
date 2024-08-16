extends HintObject

@export var fertilizer_item_data: ItemData
@export var biomass_prog_bar: ProgressBar
@export var production_prog_bar: ProgressBar

@onready var deposit_sound: AudioStreamPlayer3D = $DepositSound
@onready var producing_sound_loop: AudioStreamPlayer3D = $ProducingSound

var biomass :
	set(value):
		biomass = clamp(value, 0, 100)
		biomass_prog_bar.update_bar(biomass)

@onready var timer = $CreateFertilizerTimer

func _ready():
	self.biomass = 0
	biomass_prog_bar.init(0, 100)
	production_prog_bar.init(0, timer.wait_time)

func _process(delta):
	super(delta)
	if timer.time_left > 0:
		production_prog_bar.update_bar(timer.time_left)

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if body.slot_data.item_data.item_type == ItemData.ItemType.Biomass:
			deposit_sound.play()
			body.queue_free()
			for i in body.slot_data.quantity:
				self.biomass += 2
			if biomass >= 10:
				timer.start()
				# looping sound
				producing_sound_loop.play(0)

func _on_CreateFertilizerTimer_timeout():
	if biomass >= 10:
		var new_slot_data = SlotData.new()
		new_slot_data.item_data = fertilizer_item_data
		
		var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
		new_pickup.slot_data = new_slot_data
		get_tree().current_scene.game_world.add_child(new_pickup)
		new_pickup.global_transform.origin = $ItemSpawnPoint.global_transform.origin
		
		self.biomass -= 10
		if biomass < 10:
			timer.stop()
			producing_sound_loop.stop()
	else:
		timer.stop()
		producing_sound_loop.stop()

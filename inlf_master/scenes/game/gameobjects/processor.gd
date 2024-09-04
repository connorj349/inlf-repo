extends HintObject

var current_item_data
var count

@onready var timer = $ProcessTimer
@onready var item_spawn_point = $ItemSpawnPoint
@onready var processing_sound: AudioStreamPlayer3D = $ProcessingSound
@onready var deposit_sound: AudioStreamPlayer3D = $DepositSound
@onready var prog_bar: ProgressBar = $CanvasLayer/HintObjectInterface/HBoxContainer/VBoxContainer/StatBar

func _ready():
	prog_bar.init(0, timer.wait_time)

func _process(delta):
	super(delta)
	if timer.time_left > 0:
		prog_bar.update_bar(timer.time_left)

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if timer.is_stopped():
			if body.slot_data.item_data.processed_item_data:
				current_item_data = body.slot_data.item_data.processed_item_data
				count = body.slot_data.quantity
				timer.start()
				body.queue_free()
				processing_sound.play(0)
				deposit_sound.play()

func _on_ProcessTimer_timeout():
	var new_slot_data = SlotData.new()
	new_slot_data.item_data = current_item_data
	new_slot_data.quantity = count
	
	var new_pickup = load("res://scenes/game/item/pick_up/pickup.tscn").instantiate()
	new_pickup.slot_data = new_slot_data
	get_tree().current_scene.game_world.add_child(new_pickup)
	new_pickup.global_transform.origin = item_spawn_point.global_transform.origin
	
	processing_sound.stop()

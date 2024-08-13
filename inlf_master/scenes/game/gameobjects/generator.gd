extends Interactable

signal on_fuel_changed

@export var fuel_item_data: ItemData
@export var prog_bar: ProgressBar

var fuel = 0: set = set_fuel
var is_on = false

@onready var timer = $FuelConsumeTimer
@onready var connected_machines = $CheckForMachinesArea
@onready var startup_sound: AudioStreamPlayer3D = $StartupSound
@onready var loop_sound: AudioStreamPlayer3D = $LoopSound
@onready var spindown_sound: AudioStreamPlayer3D = $SpindownSound
@onready var click_empty_sound: AudioStreamPlayer3D = $ClickSound

func _ready():
	prog_bar.init(0, 100)
# warning-ignore:return_value_discarded
	connect("on_fuel_changed", Callable(prog_bar, "update_bar"))
	await get_tree().process_frame
	change_active_status_of_machines(false)

func _interact(_actor):
	if fuel <= 0:
		click_empty_sound.play()
		return
	
	self.is_on = !self.is_on
	
	if is_on:
		self.fuel -= 1
		timer.start()
		change_active_status_of_machines(true)
		startup_sound.play()
		loop_sound.play(0)
	else:
		timer.stop()
		change_active_status_of_machines(false)
		spindown_sound.play()
		loop_sound.stop()

func change_active_status_of_machines(is_active):
	for body in connected_machines.get_overlapping_bodies():
		if body.is_in_group("machine"):
			body.can_interact = is_active

func set_fuel(value):
	fuel = clamp(value, 0, 100)
	emit_signal("on_fuel_changed", fuel)

func _on_ItemDeposit_body_entered(body):
	if body.is_in_group("pickup"):
		if fuel_item_data and body.slot_data.item_data == fuel_item_data:
			body.queue_free()
			self.fuel += 25

func _on_FuelConsumeTimer_timeout():
	self.fuel -= 1
	if fuel <= 0:
		change_active_status_of_machines(false)
		return
	timer.start()

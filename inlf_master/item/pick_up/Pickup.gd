extends Interactable

export(Resource) var slot_data

onready var sprite_3d = $Sprite3D
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Name
onready var sound_queue = $SoundQueue3D

var factor = 1

func _ready():
	sprite_3d.texture = slot_data.item_data.texture
	name_plate.text = slot_data.item_data.name
	if !is_in_group("pickup"):
		add_to_group("pickup")

func _interact(_actor):
	if Gamestate.player_inventory.pick_up_slot_data(slot_data):
		queue_free()

func _on_Pickup_body_entered(_body):
	if abs(self.linear_velocity.x) > factor or abs(self.linear_velocity.y) > factor or abs(self.linear_velocity.z) > factor:
		sound_queue.PlaySoundRange(0.9, 1.1)

func _on_Timer_timeout(): # delete this object if left out in the open for too long
	queue_free()

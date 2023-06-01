extends Interactable

export(Resource) var slot_data

onready var sprite_3d = $Sprite3D
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Name

func _ready():
	sprite_3d.texture = slot_data.item_data.texture
	name_plate.text = slot_data.item_data.name

func _interact(_actor):
	if Gamestate.player_inventory.pick_up_slot_data(slot_data):
		queue_free()

extends Interactable

export(Resource) var slot_data

onready var sprite_3d = $Sprite3D
onready var name_plate = $CanvasLayer/Info/VBoxContainer/Name
onready var anim_player = $AnimationPlayer

func _ready():
	sprite_3d.texture = slot_data.item_data.texture
	name_plate.text = slot_data.item_data.name

func _interact(_actor):
	if Gamestate.player_inventory.pick_up_slot_data(slot_data):
		queue_free()

func _display_info(): #override, can even add sounds to this as it's not played dozens of times
	anim_player.play("fade_in")

func _hide_info(): #play animation in reverse
	anim_player.play_backwards("fade_in")

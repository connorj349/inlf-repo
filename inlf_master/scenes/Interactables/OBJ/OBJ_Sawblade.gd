extends Spatial

# IDEAS
# -setup player permissions so that the player is only allowed to do certain things w/ certain roles
# -instead of permissions, start the player off with certain gear?(need to generate a way to lose this gear on death)

export var role_name = ""
export var instructions = ""
export var description = ""
export var pay_option = ""

onready var role_label = $Viewport/VBoxContainer/RoleLabel
onready var instruction_label = $Viewport/VBoxContainer/InstrucLabel
onready var description_label = $Viewport/VBoxContainer/DescLabel
onready var pay_label = $Viewport/VBoxContainer/PayLabel #optional for early development

var player_prefab = preload("res://scenes/Characters/Player/Player.tscn") #player base prefab

func _ready():
	role_label.text = role_name
	instruction_label.text = instructions
	description_label.text = description
	pay_label.text = pay_option

func _on_Area_body_entered(body): #maybe change this to some kind of interaction instead
	if body.is_in_group("Ghost"):
		var player = player_prefab.instance()
		get_tree().get_root().add_child(player)
		player.global_transform = global_transform
		player.add_to_group("other_dev") #for dev testing
		body.queue_free() #delete player ghost

extends Spatial

# add ability to spawn the player with certian items/spells

export var instructions = "none" # generic talk to give the item a mood
export(Resource) var role

onready var role_label = $Viewport/VBoxContainer/RoleLabel
onready var instruction_label = $Viewport/VBoxContainer/InstrucLabel
onready var description_label = $Viewport/VBoxContainer/DescLabel
onready var cooldown_timer = $Timer

var player_prefab = preload("res://Characters/Player/Player.tscn") #player base prefab

func _ready():
	if role:
		cooldown_timer.wait_time = role.cooldown # needs to be greater than 0
		role_label.text = role.name
		instruction_label.text = instructions
		description_label.text = role.description

func _on_Area_body_entered(body):
	if role.role_type == Role.Role_Type.ANTAGONIST and Gamestate.rot > Globals.max_rot_allowed_for_antagonist_join: #maybe make this a GLOBAL const
		return # if the rot is above a certain amount, the player cannot become this role

	if role: # prevent any errors
		if cooldown_timer.time_left <= 0:
			if body.is_in_group("Ghost"):
				cooldown_timer.start()
				var player = player_prefab.instance()
				get_tree().get_root().add_child(player)
				player.global_transform = global_transform
				player.set_role(role)
				body.queue_free() #delete player ghost

func _on_Timer_timeout(): #maybe use the regular not 3d playsound
	pass #nothing for now, maybe play a special distant sound to alert the player subconsiously when a role is available

extends Node3D

@export var instructions = "none" # generic talk to give the item a mood
@export var role: Resource
@export var required_items = [] # (Array, Resource)
@export var optional_random_items = [] # (Array, Resource)
@export var random_amount_of_items_to_give: int = 0
@export var player_prefab: PackedScene # have this instead spawn the player as player_cultist, REMOVE ROLE

@onready var role_label = $SubViewport/VBoxContainer/RoleLabel
@onready var instruction_label = $SubViewport/VBoxContainer/InstrucLabel
@onready var description_label = $SubViewport/VBoxContainer/DescLabel
@onready var cooldown_timer = $Timer
var random_item_count
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if role:
		cooldown_timer.wait_time = role.cooldown # needs to be greater than 0
		role_label.text = role.name
		instruction_label.text = instructions
		description_label.text = role.description

func _on_Area_body_entered(body):
	if role: # prevent any errors
		if cooldown_timer.time_left <= 0:
			if body.is_in_group("Ghost"):
				random_item_count = rng.randi_range(0, random_amount_of_items_to_give)
				cooldown_timer.start()
				var player = player_prefab.instantiate()
				get_tree().get_root().add_child(player)
				player.global_transform = global_transform
				player.set_role(role)
				body.queue_free()
				Gamestate.emit_signal("on_player_spawn", role.stem_cell_cost)
				if optional_random_items.size() > 0:
					for i in random_item_count:
						var new_item = SlotData.new()
						new_item.item_data = optional_random_items[rng.randi_range(0, optional_random_items.size() - 1)]
						Gamestate.player_inventory.add_item(new_item)
				if required_items.size() > 0:
					for i in required_items.size():
						var new_item = SlotData.new()
						new_item.item_data = required_items[i]
						Gamestate.player_inventory.add_item(new_item)

func _on_Timer_timeout(): #maybe use the screenspace not 3d playsound
	pass #nothing for now, maybe play a special distant sound to alert the player subconsiously when a role is available

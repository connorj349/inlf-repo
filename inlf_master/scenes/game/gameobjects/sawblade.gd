extends Node3D

@export var player_prefab: PackedScene
@export var stem_cell_cost: int = 1
@export var random_amount_of_items_to_give: int = 0
@export var required_items: Array[ItemData]
@export var optional_random_items: Array[ItemData]

var random_item_count: int
var rng = RandomNumberGenerator.new()

@onready var role_available_sound: AudioStreamPlayer = $RoleAvailableSound
@onready var cooldown_timer: Timer = $Timer

func _ready():
	rng.randomize()

func _on_Area_body_entered(body):
	if cooldown_timer.time_left <= 0:
		if body.is_in_group("Ghost"):
			random_item_count = rng.randi_range(0, random_amount_of_items_to_give)
			
			cooldown_timer.start()
			
			var player = player_prefab.instantiate()
			
			get_tree().current_scene.game_world.add_child(player)
			
			player.global_transform = global_transform
			
			player.health.connect("dead", Callable(get_tree().current_scene.game_world.current_level, "handle_player_death"))
			
			body.queue_free()
			
			get_tree().current_scene.game_world.current_level.handle_player_spawn(stem_cell_cost)
			
			if optional_random_items.size() > 0:
				for i in random_item_count:
					var new_item = SlotData.new()
					new_item.item_data = optional_random_items[rng.randi_range(0, optional_random_items.size() - 1)]
					
					# player.inventory.add_item(new_item) should be adding items to inventory directly on player
					Gamestate.player_inventory.add_item(new_item)
			
			if required_items.size() > 0:
				for i in required_items.size():
					var new_item = SlotData.new()
					new_item.item_data = required_items[i]
					
					# player.inventory.add_item(new_item) should be adding items to inventory directly on player
					Gamestate.player_inventory.add_item(new_item)

func _on_Timer_timeout():
	role_available_sound.play()

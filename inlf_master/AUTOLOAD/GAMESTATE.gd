extends Node
## gamestate should really only keep track of player progress
## like if the player has unlocked maps, how many wins/loss, etc.
##
## when player loads up game, read save file that holds data about
## what maps the player has unlocked from completing certain win conditions
## i.e. cultist win, worker win, etc.

signal rot_changed
signal bones_changed
# warning-ignore:unused_signal
signal on_player_death
# warning-ignore:unused_signal
signal on_player_spawn
# warning-ignore:unused_signal
signal on_stem_cells_changed
signal infections_count_changed
# warning-ignore:unused_signal
signal game_over

# each of these should be created at runtime instead of referenced like this
# player's inventory
var player_inventory = load("res://scenes/game/inventory/player_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = load("res://scenes/game/inventory/player_equipment_inventory.tres")
# player's weapon slot
var weapon_player_inventory = load("res://scenes/game/inventory/player_weapon_inventory.tres")
# global merchant inventory for all vendors to reference
var merchant_inventory = load("res://scenes/game/inventory/merchant_inventory.tres")

var rot: int = 0 :
	set(value):
		rot = clamp(value, 0, Globals.rot_max_value)
		if rot >= Globals.rot_max_value:
			emit_signal("game_over")
		emit_signal("rot_changed")

# reduce below to 0 when done testing
var bones: int = 100 :
	set(value):
		bones = clamp(value, 0, 9999)
		emit_signal("bones_changed", bones)
		if value > 0:
			Globals.emit_signal("on_pop_notification", "I received some bones.")
		elif value < 0:
			Globals.emit_signal("on_pop_notification", "I have lost some bones.")

var bloaters: int = 0 :
	set(value):
		bloaters = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var tumors: int = 0 :
	set(value):
		tumors = clamp(value, 0, 9999)
		emit_signal("infections_count_changed")

var infections: int :
	get:
		return bloaters + tumors

var spawn_queue = []
var cache = {}

func _ready():
# warning-ignore:return_value_discarded
	connect("game_over", Callable(self, "reset_gamestate"))

func _physics_process(_delta):
	dequeue_spawn_requests()

func dequeue_spawn_requests():
	if spawn_queue.size() == 0:
		return
	var spawn_request_info = spawn_queue.pop_front()
	var spawner = spawn_request_info.spawner
	spawner.spawn()
	cache.erase(str(spawner))

func request_spawn(spawner):
	var key = str(spawner) # create a unique key per spawn request
	if key in cache:
		return
	cache[key] = ""
	spawn_queue.append({"spawner" : spawner})

func reset_gamestate():
	self.bones = 0
	self.rot = 0
	self.bloaters = 0
	self.tumors = 0
	for i in player_inventory.slot_datas:
		player_inventory.take_item(i)
	for i in equip_player_inventory.slot_datas:
		equip_player_inventory.take_item(i)
	for i in weapon_player_inventory.slot_datas:
		weapon_player_inventory.take_item(i)
	for i in merchant_inventory.slot_datas:
		merchant_inventory.take_item(i)

func reset_player_state():
	for i in player_inventory.slot_datas:
		player_inventory.take_item(i)
	for i in equip_player_inventory.slot_datas:
		equip_player_inventory.take_item(i)
	for i in weapon_player_inventory.slot_datas:
		weapon_player_inventory.take_item(i)

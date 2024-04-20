extends Node

# player's inventory
var player_inventory = preload("res://inventory/player_inventory.tres")
# player's clothing equipment slot
var equip_player_inventory = preload("res://inventory/player_equipment_inventory.tres")
# player's weapon slot
var weapon_player_inventory = preload("res://inventory/player_weapon_inventory.tres")
# global merchant inventory for all vendors to reference
var merchant_inventory = preload("res://inventory/merchant_inventory.tres")

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

var rot = 0 setget set_rot
var bones = 0 setget set_bones
var bloaters = 0 setget set_bloaters
var tumors = 0 setget set_tumors
var infections setget , get_infections

var spawn_queue = []
var cache = {}

func _ready():
# warning-ignore:return_value_discarded
	connect("game_over", self, "reset_gamestate")

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

func set_rot(value):
	rot = clamp(value, 0, Globals.rot_max_value)
	if rot >= Globals.rot_max_value:
		# fade out to black screen, display text ROT CONSUMED THE WORLD
		return
	emit_signal("rot_changed")

func set_bones(value):
	bones = clamp(value, 0, 9999)
	emit_signal("bones_changed", bones)
	if value > 0:
		Globals.emit_signal("on_pop_notification", "I received some bones.")
	elif value < 0:
		Globals.emit_signal("on_pop_notification", "I have lost some bones.")

func set_bloaters(value):
	bloaters = clamp(value, 0, 9999)
	emit_signal("infections_count_changed")

func set_tumors(value):
	tumors = clamp(value, 0, 9999)
	emit_signal("infections_count_changed")

func get_infections():
	return bloaters + tumors

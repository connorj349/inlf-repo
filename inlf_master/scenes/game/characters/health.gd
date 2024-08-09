extends Node3D

signal dead
signal health_changed
signal max_health_changed(health: int, maxhealth: int)
signal pox_changed

@export var allowed_max_health: int = 1

var pox: int = 0: set = set_pox
var parasite # need to create parasite Resource and setters
# need to create timer that will perform actions based on parasite player has
var max_health: int = 1: get = get_max_health, set = set_max_health
var health: int = 1: set = set_health

func init():
	self.max_health = allowed_max_health
	self.health = max_health
	self.pox = 0

func set_pox(val):
	pox = clamp(val, 0, allowed_max_health)
	self.max_health = self.max_health
	pox_changed.emit(pox)

func set_max_health(val):
	max_health = clamp(val, 0, allowed_max_health)
	if health > self.max_health:
		self.health = self.max_health
	max_health_changed.emit(health, max_health)

func get_max_health():
	return allowed_max_health - pox

func set_health(val):
	health = clamp(val, 0, self.max_health)
	health_changed.emit(health)
	if health <= 0:
		dead.emit()

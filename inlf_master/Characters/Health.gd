extends Spatial

export(int) var allowed_max_health = 1

var pox = 0 setget set_pox
var parasite # need to create parasite Resource and setters
# need to create timer that will perform actions based on parasite player has
var max_health = 1 setget set_max_health
var health = 1 setget set_health

signal dead
signal health_changed
signal max_health_changed
signal pox_changed

func init():
	max_health = allowed_max_health
	health = max_health
	pox = 0

func set_pox(val):
	pox = clamp(val, 0, allowed_max_health)
	max_health = max_health
	emit_signal("pox_changed", pox)

func set_max_health(val):
	max_health = clamp(val - pox, 0, allowed_max_health)
	if health > max_health:
		health = max_health
	emit_signal("max_health_changed", max_health)

func set_health(val):
	health = clamp(val, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("dead")

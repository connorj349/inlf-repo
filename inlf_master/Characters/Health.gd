extends Spatial

export(int) var max_health = 1

var health = 1

signal hurt #sends 1 arg; remaning health to update uis
signal heal #sends 1 arg; reamining health
signal dead
signal health_changed #sends 1 arg; remaining health

func init():
	health = max_health
	emit_signal("health_changed", health)

func hurt(amount):
	health = clamp(health - amount, 0, max_health)
	emit_signal("hurt", health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("dead")

func heal(amount):
	health = clamp(health + amount, 0, max_health)
	emit_signal("heal", health)
	emit_signal("health_changed", health)

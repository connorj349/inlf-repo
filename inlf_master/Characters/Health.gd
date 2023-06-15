extends Spatial

export(int) var max_health = 1
export(AudioStream) var hurt_audio_stream
export(AudioStream) var death_audio_stream
export(PackedScene) var hit_effect = preload("res://effects/blood_spray.tscn")

onready var hurt_sound = $hurt_sound
onready var death_sound = $death_sound

var health = 1

signal hurt #sends 1 arg; remaning health to update uis
signal heal #sends 1 arg; reamining health
signal dead
signal health_changed #sends 1 arg; remaining health

func init():
	health = max_health
	hurt_sound.stream = hurt_audio_stream
	death_sound.stream = death_audio_stream
	emit_signal("health_changed", health)

func hurt(amount):
	if hit_effect:
		var hit = hit_effect.instance()
		get_tree().get_root().add_child(hit)
		hit.global_transform.origin = self.global_transform.origin
	health = clamp(health - amount, 0, max_health)
	hurt_sound.play()
	emit_signal("hurt", health)
	emit_signal("health_changed", health)
	if health <= 0:
		death_sound.play()
		emit_signal("dead")

func heal(amount):
	health = clamp(health + amount, 0, max_health)
	emit_signal("heal", health)
	emit_signal("health_changed", health)

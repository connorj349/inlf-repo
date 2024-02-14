extends Interactable

var is_broken = false
var health = 100
var rng = RandomNumberGenerator.new()

func _ready():
	randomize()

func on_interact(_actor):
	if !is_broken:
		health = clamp(health - 10, 0, 100)
		if health <= 0:
			is_broken = true
			can_interact = !is_broken
	else:
		#var random_chance = 
		pass

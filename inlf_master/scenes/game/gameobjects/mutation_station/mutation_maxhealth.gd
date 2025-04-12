extends Mutation
class_name MutationMaxHealth

@export var added_health: int

func apply(player):
	player.health.allowed_max_health += added_health
	player.health.max_health += added_health

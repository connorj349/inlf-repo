extends RitualRecipe
class_name SummonRitual

@export var summonable_object: PackedScene

func perform_ritual(ritual_origin: Node3D):
	var new_summon = summonable_object.instantiate()
	ritual_origin.get_tree().current_scene.game_world.current_level.add_child(new_summon)
	new_summon.global_position = ritual_origin.global_position

extends Resource
class_name RitualRecipe

@export var recipe_name: String # testing
@export var organs_needed: Array[ItemDataOrgan]

## virtual methods

# override in extended ritual recipes for specific ritual functionality
func perform_ritual(_ritual_origin: Node3D):
	pass

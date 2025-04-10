extends Resource
class_name RitualRecipe

@export var recipe_name: String # testing
@export var organs_needed: Array[ItemDataOrgan]

## virtual methods

# override in extended ritual recipes for specific ritual functionality
func perform_ritual():
	# ex. create an effect that heals the player/spawn a tumor/etc.
	pass

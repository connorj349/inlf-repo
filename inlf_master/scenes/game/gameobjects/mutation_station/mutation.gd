extends Resource
class_name Mutation

@export var name: String
@export_multiline var description: String
@export var cost: int
@export var icon: Texture

## virtual methods

# override in extended mutations
func apply(_player):
	pass

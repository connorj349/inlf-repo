extends Resource
class_name Role

enum Role_Type {
	Worker,
	Police,
	Cultist,
	OTHER
}

@export var name: String = ""
@export var description: String = ""
@export var cooldown: float = 0.0 #how long before the player can play as this role again
@export var role_type: Role_Type = Role_Type.OTHER
@export var stem_cell_cost: int = 1

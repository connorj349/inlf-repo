extends Resource
class_name Role

enum Role_Type {
	Worker,
	Police,
	Cultist,
	OTHER
}

export(String) var name = ""
export(String) var description = ""
export(float) var cooldown = 0.0 #how long before the player can play as this role again
export(Role_Type) var role_type = Role_Type.OTHER

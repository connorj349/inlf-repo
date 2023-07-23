extends Resource
class_name Role

enum Role_Type {
	ANTAGONIST,
	PROTAGONIST,
	OTHER
}

export(String) var name = ""
export(String) var description = ""
export(Texture) var portrait_image = preload("res://raw_assets/textures/portraits/other_portrait.png")
export(float) var cooldown = 0.0 #how long before the player can play as this role again
export(Role_Type) var role_type = Role_Type.OTHER

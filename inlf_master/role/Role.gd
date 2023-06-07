extends Resource
class_name Role

export(String) var name
export(String) var description
export(int) var stem_cells_required = 0 # how many stem cells it costs to become this role
export(Texture) var portrait_image = preload("res://raw_assets/textures/portraits/other_portrait.png")
export(float) var cooldown = 0.0 #how long before the player can play as this role again

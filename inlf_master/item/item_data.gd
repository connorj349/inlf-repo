extends Resource
class_name ItemData

export(String) var name = ""
export(String, MULTILINE) var description  = ""
export(bool) var stackable = false
export(AtlasTexture) var texture
export(int) var price = 0
export(bool) var drop_on_death = false
export(Resource) var processed_item_data

# warning-ignore:unused_argument
func use(target): #override for child classes
	pass

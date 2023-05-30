extends Resource
class_name ItemData

export(String) var name = ""
export(String, MULTILINE) var description  = ""
export(bool) var stackable = false
export(AtlasTexture) var texture

# warning-ignore:unused_argument
func use(target): #override for child classes
	pass

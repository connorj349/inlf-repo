extends ItemData
class_name ItemDataOrgan

@export var mana_regen: int = 1 # the amount of magick to provide on consumption

func use(target):
	target.on_use_organ(self)

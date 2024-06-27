extends ItemData
class_name ItemDataOrgan

@export var mana_regen: int = 1 # the amount of magick to provide on consumption
@export var magic_effect: PackedScene # the effect that the player will spawn if within ritual circle

func use(target):
	target.on_use_organ(self)

extends ItemData
class_name ItemDataOrgan

export(int) var mana_regen = 1 # the amount of magick to provide on consumption
export(PackedScene) var magic_effect # the effect that the player will spawn if within ritual circle

func use(target):
	target.on_use_organ(self)

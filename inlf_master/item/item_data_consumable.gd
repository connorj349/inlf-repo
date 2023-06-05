extends ItemData
class_name ItemDataConsumable

export(int) var heal_value

func use(target):
	if heal_value != 0:
		target.on_heal(heal_value) #use the on_heal method on the target

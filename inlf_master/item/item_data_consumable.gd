extends ItemData
class_name ItemDataConsumable

enum ConsumableType {
	HEALTH,
	ARMOR
}

@export var heal_value: int
@export var consumable_type: ConsumableType

func use(target):
	if heal_value != 0:
		match(consumable_type):
			ConsumableType.HEALTH:
				target.on_heal(heal_value) # use the on_heal method on the target
			ConsumableType.ARMOR:
				target.give_armor(heal_value) # use give_armor method on the target

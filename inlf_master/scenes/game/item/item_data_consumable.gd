extends ItemData
class_name ItemDataConsumable

enum ConsumableType {
	HEALTH,
	ARMOR
}

@export var heal_value: int = 0
@export var money_gain_value: int
@export var consumable_type: ConsumableType

func use(target):
	if heal_value != 0:
		match(consumable_type):
			ConsumableType.HEALTH:
				if heal_value > 0:
					target.on_heal(heal_value, true) # use the on_heal method on the target
				else:
					var damage = Damage.new()
					damage.amount = -heal_value
					target.on_hurt(damage)
			ConsumableType.ARMOR:
				target.give_armor(heal_value) # use give_armor method on the target
	
	if money_gain_value != 0:
		Gamestate.bones += money_gain_value

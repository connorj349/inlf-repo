extends Resource
class_name Damage

enum DamageType {
	Fists,
	Bullet,
	Blunt,
	Sharp
}

@export var type: DamageType # the type of damage
@export var amount: int # the amount of damage to be dealt
var source = null # set by the damage dealer

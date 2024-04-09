extends Resource
class_name Damage

enum DamageType {
	Fists,
	Bullet,
	Blunt,
	Sharp
}

export(DamageType) var type # the type of damage
export(int) var amount # the amount of damage to be dealt
var source = null # set by the damage dealer

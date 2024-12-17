extends Resource
class_name Damage
## Damage Class
##
## used by the player's weapons and npcs and misc gameobjects
## damage type will determine if objects like resource_nodes takes damage or not
## the source is used to set an NPC's target when being attacked

enum DamageType {
	Fists,
	Bullet,
	Blunt,
	Sharp
}

@export var type: DamageType # the type of damage
@export var amount: int = 0 # the amount of damage to be dealt
var source = null # set by the damage dealer

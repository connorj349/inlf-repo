extends Resource
class_name ItemData

enum ItemType {
	Biomass,
	Fertilizer,
	Water,
	Exotic,
	NONE
}

@export var name: String
@export_multiline var description: String
@export var stackable: bool = false
@export var texture: AtlasTexture
@export var price: int = 0
@export var processed_item_data: Resource
@export var item_type: ItemType = ItemType.NONE

# warning-ignore:unused_argument
func use(_target): #override for child classes
	pass

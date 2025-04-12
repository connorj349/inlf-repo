extends Interactable
## Dark Altar
##
## Acts as a storage for organs, but when the player draws a circle, a ritual occurs

signal toggle_inventory(external_inventory_owner)

@export var ritual_recipes: Array[RitualRecipe]
@export var inventory_data: InventoryDataOrgan

@onready var sound_queue = $SoundQueue

func _ready():
# warning-ignore:return_value_discarded
	connect("toggle_inventory", Callable(Globals, "toggle_inventory_interface"))

# only allow interacting if the player is a cultist
func _interact(actor):
	if actor is PlayerCultist:
		sound_queue.PlaySound()
		emit_signal("toggle_inventory", self)
	else:
		Globals.on_pop_notification.emit("Looks like a sinister altar. I don't wanna mess with this.")

## public methods

# this get's called by the circle the player draws
func begin_ritual():
	var recipe = get_valid_recipe()
	if recipe:
		Globals.on_pop_notification.emit("I have performed a ritual successfully!")
	else:
		Globals.on_pop_notification.emit("I need the right combination of organs to perform a ritual.")

## private methods

# returns a recipe that contains all items within this inventory data and removes items
func get_valid_recipe():
	if inventory_data.slot_datas.size() > 0:
		for recipe in ritual_recipes:
			var has_all_organs = true
			
			for _item_data in recipe.organs_needed:
				var item_found = false
				
				for slot_data in inventory_data.slot_datas:
					if slot_data == null:
						break
					
					if slot_data.item_data == _item_data:
						item_found = true
						break
				
				if not item_found:
					has_all_organs = false
					break
			
			if has_all_organs:
				for _item_data in recipe.organs_needed:
					var slot = SlotData.new()
					slot.item_data = _item_data
					inventory_data.take_item(slot)
				
				return recipe
	
	return null

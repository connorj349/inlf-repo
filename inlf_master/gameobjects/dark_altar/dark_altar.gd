extends Interactable

export(Array, Resource) var possible_materials # the materials that could be required for a ritual

onready var label = $CanvasLayer/Info/VBoxContainer/Label2 # display ritual requirements

var current_active_required_mat
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _interact(_actor): # can only use if player is an antagonist
	if _actor.role.role_type == Role.Role_Type.Cultist:
		if current_active_required_mat:
			if Gamestate.player_inventory.take_item(current_active_required_mat):
				Globals.current_player.magick.increase_max_magick(1) # increase max magick +1
				Gamestate.rot_modify(1) # increase rot
				Globals.emit_signal("on_pop_notification", "[color=#33FFF3]My knowledge in the arcane has increased[/color]")
				Globals.emit_signal("on_pop_notification", "[color=red]The rot grows[/color]")
				label.text = "interact with to start a gruesome ritual"
				current_active_required_mat = null # remove reference
		else:
			if possible_materials.size() > 0:
				var random_index = rng.randi_range(0, possible_materials.size() - 1)
				current_active_required_mat = possible_materials[random_index]
				label.text = "offer a %s to the dark altar to complete the ritual" % current_active_required_mat.item_data.name

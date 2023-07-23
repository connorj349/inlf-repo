extends Interactable

# on interact, begin random ritual
# on ritual complete, award +1 maximum magick
export(Array, Resource) var possible_materials # the materials that could be required for a ritual

onready var label = $CanvasLayer/Info/VBoxContainer/Label2 # display ritual requirements

var current_active_required_mat
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _interact(_actor): # can only use if player is an antagonist
	if _actor.role.role_type == Role.Role_Type.ANTAGONIST:
		if current_active_required_mat:
			if Gamestate.player_inventory.take_item(current_active_required_mat):
				# increase player max magick
				Gamestate.rot_modify(1)
				Globals.emit_signal("on_pop_notification", "My knowledge in the arcane has increased")
				Globals.emit_signal("on_pop_notification", "The rot grows")
				label.text = "interact with to start a gruesome ritual"
				current_active_required_mat = null
		else:
			if possible_materials.size() > 0:
				var random_index = rng.randi_range(0, possible_materials.size() - 1)
				current_active_required_mat = possible_materials[random_index]
				label.text = "offer a %s to the dark altar to complete the ritual" % current_active_required_mat.item_data.name

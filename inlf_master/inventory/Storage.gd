extends Interactable
class_name Storage

# add a subset of storages that can has a chance to "lose/have stolen" from after set amount of time
# after not being interacted with
# make it so that storages can auto-populate with items/random loot, this loot disappears after awhile

signal toggle_inventory(external_inventory_owner)

export(Resource) var inventory_data

onready var anim_player = $AnimationPlayer

func _interact(_actor):
	emit_signal("toggle_inventory", self)

func _display_info(): #override, can even add sounds to this as it's not played dozens of times
	anim_player.play("fade_in")

func _hide_info(): #play animation in reverse
	anim_player.play_backwards("fade_in")

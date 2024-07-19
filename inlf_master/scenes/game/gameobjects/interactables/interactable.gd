extends HintObject
class_name Interactable

var can_interact = true

func _ready():
	if !is_in_group("interactable"):
		add_to_group("interactable")

func _interact(_actor): #overridable method
	pass

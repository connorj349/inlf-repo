extends Spatial

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("area_infected", self, "on_infect")

func on_infect():
	for child in get_children():
		child.spawn()

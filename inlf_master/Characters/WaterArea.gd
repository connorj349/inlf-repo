extends Area
tool

export(Vector3) var bounds = Vector3(1, 1, 1)

onready var collision_shape = $CollisionShape

func _ready():
	collision_shape.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		collision_shape.shape.extents = bounds

func _on_WaterArea_area_entered(area):
	area.submerged = true

func _on_WaterArea_area_exited(area):
	area.submerged = false

@tool
extends Area3D

@export var bounds: Vector3 = Vector3(1, 1, 1)

func _ready():
	$CollisionShape3D.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		$CollisionShape3D.shape.extents = bounds

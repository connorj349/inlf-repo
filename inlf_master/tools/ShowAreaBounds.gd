extends Area
tool

export(Vector3) var bounds = Vector3(1, 1, 1)

func _ready():
	$CollisionShape.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		$CollisionShape.shape.extents = bounds

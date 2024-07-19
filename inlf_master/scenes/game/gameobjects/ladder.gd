@tool
extends Area3D

@export var bounds: Vector3 = Vector3(1, 1, 1)

@onready var collision_shape = $CollisionShape3D

func _ready():
	collision_shape.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		$CollisionShape3D.shape.extents = bounds

func _on_Ladder_body_entered(body):
	if body.name == "Player":
		body.movement.ladder_array.append(self)
		body.movement.current_state = body.movement.State.LADDER

func _on_Ladder_body_exited(body):
	if body.name == "Player":
		body.movement.ladder_array.erase(self)
		if body.movement.ladder_array.size() == 0:
			body.movement.current_state = body.movement.State.NORMAL

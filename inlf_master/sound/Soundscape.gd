extends Spatial
tool

export(float) var Radius = 1.0

func _ready():
	pass

func _process(_delta):
	if Engine.is_editor_hint():
		$Area/CollisionShape.shape.radius = Radius

func _on_Area_body_entered(body):
	if body == Globals.current_player:
		pass #fade in sound pool

func _on_Area_body_exited(body):
	if body == Globals.current_player:
		pass #fade out sound pools

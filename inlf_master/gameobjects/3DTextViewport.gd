tool
extends Viewport

#really want to get rid of this entirely as it's only used by the sawblade gameobject

func _process(_delta):
	size = $VBoxContainer.rect_size

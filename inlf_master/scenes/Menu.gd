extends Spatial

# get reference to options menu

# add methods for each MENU button
# add methods for each OPTIONS button WITHIN the actual options menu itself, NOT menu

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_StartButton_button_down():
	# play click button sound
	$CanvasLayer/LoadingScreen.change_scene("res://scenes/Main.tscn") # change scene, passing menu as current_scene
	$CanvasLayer/StartButton.hide() # hide the button
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ExitButton_pressed():
	get_tree().quit()

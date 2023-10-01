extends Spatial

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_StartButton_button_down():
	SoundManager.Play_UI_ButtonPress()
	$CanvasLayer/LoadingScreen.change_scene("res://scenes/Main.tscn") # change scene, passing menu as current_scene
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	SoundManager.Play_UI_ButtonPress()
	$CanvasLayer/Options.visible = true

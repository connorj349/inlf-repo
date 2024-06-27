extends Control

func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		toggle()

func toggle():
	visible = !visible
	get_tree().paused = visible
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_options_button_pressed():
	$Options.visible = true
	SoundManager.Play_UI_ButtonPress()

func _on_menu_exit_button_pressed():
	toggle()
	Gamestate.reset_gamestate()
	$LoadingScreen.change_scene_to_file("res://scenes/Menu.tscn")
	SoundManager.Play_UI_ButtonPress()

func _on_exit_button_pressed():
	Gamestate.reset_gamestate()
	get_tree().quit()

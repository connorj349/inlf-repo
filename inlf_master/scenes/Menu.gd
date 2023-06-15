extends Spatial

onready var sound_queue = $SoundQueue

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_StartButton_button_down():
	sound_queue.PlaySound()
	$CanvasLayer/LoadingScreen.change_scene("res://scenes/Main.tscn") # change scene, passing menu as current_scene
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	sound_queue.PlaySound()
	$CanvasLayer/Options.visible = true

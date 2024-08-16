extends TextureRect

signal starting

@onready var start_fx: AudioStreamPlayer = $StartFX
@onready var button_press: AudioStreamPlayer = $ButtonPressSoundFX

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	ScreenFader.fade_in()

func _on_StartButton_button_down():
	ScreenFader.fade_out()
	start_fx.play()
	starting.emit()
	button_press.play()
	
	await start_fx.finished
	
	queue_free()
	
	#$CanvasLayer/LoadingScreen.change_scene_to_file("res://scenes/main.tscn") # change scene, passing menu as current_scene
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	button_press.play()
	$Options.visible = true

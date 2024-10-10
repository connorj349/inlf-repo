extends Control

@onready var button_press: AudioStreamPlayer = $ButtonPressSound

func _ready():
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/fullscreen_check.button_pressed = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/borderless_check2.button_pressed = get_window().borderless
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/vsync_check3.button_pressed = (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED)

func _on_Button_pressed():
	button_press.play() # maybe make this a different sound queue to play a diff noise for closing out
	visible = false # turn visibility off to "go back" to prev window

func _on_fullscreen_check_toggled(button_pressed):
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (button_pressed) else Window.MODE_WINDOWED
	button_press.play()

func _on_borderless_check2_toggled(button_pressed):
	get_window().borderless = button_pressed
	button_press.play()

func _on_vsync_check3_toggled(button_pressed):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (button_pressed) else DisplayServer.VSYNC_DISABLED)
	button_press.play()

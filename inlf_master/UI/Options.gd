extends Control

func _ready():
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/fullscreen_check.pressed = OS.window_fullscreen
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/borderless_check2.pressed = OS.window_borderless
	$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/vsync_check3.pressed = OS.vsync_enabled

func _on_Button_pressed():
	SoundManager.Play_UI_ButtonPress() # maybe make this a different sound queue to play a diff noise for closing out
	visible = false # turn visibility off to "go back" to prev window

func _on_fullscreen_check_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	SoundManager.Play_UI_ButtonPress()

func _on_borderless_check2_toggled(button_pressed):
	OS.window_borderless = button_pressed
	SoundManager.Play_UI_ButtonPress()

func _on_vsync_check3_toggled(button_pressed):
	OS.vsync_enabled = button_pressed
	SoundManager.Play_UI_ButtonPress()

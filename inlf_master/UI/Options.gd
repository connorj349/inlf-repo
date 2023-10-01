extends Control

func _ready():
	$Panel/MarginContainer/VBoxContainer/fullscreen_check.pressed = OS.window_fullscreen
	$Panel/MarginContainer/VBoxContainer/borderless_check2.pressed = OS.window_borderless
	$Panel/MarginContainer/VBoxContainer/vsync_check3.pressed = OS.vsync_enabled
	$Panel/MarginContainer/VBoxContainer/video_sliders/sliders/master_slider.value = AudioServer.get_bus_volume_db(0)
	$Panel/MarginContainer/VBoxContainer/video_sliders/sliders/music_slider.value = AudioServer.get_bus_volume_db(1)
	$Panel/MarginContainer/VBoxContainer/video_sliders/sliders/sfx_slider.value = AudioServer.get_bus_volume_db(2)

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

func _on_master_slider_value_changed(value):
	volume(0, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_music_slider_value_changed(value):
	volume(1, value)

func _on_sfx_slider_value_changed(value):
	volume(2, value)

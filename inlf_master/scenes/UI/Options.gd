extends Control

func _ready():
	pass

func _on_Button_pressed():
	visible = false # turn visibility off to "go back" to prev window

func _on_fullscreen_check_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func _on_borderless_check2_toggled(button_pressed):
	OS.window_borderless = button_pressed

func _on_vsync_check3_toggled(button_pressed):
	OS.vsync_enabled = button_pressed

func _on_master_slider_value_changed(value):
	volume(0, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_music_slider_value_changed(value):
	volume(1, value)

func _on_sfx_slider_value_changed(value):
	volume(2, value)

extends TextureRect

signal starting(level_name: String)

@onready var start_fx: AudioStreamPlayer = $StartFX
@onready var button_press: AudioStreamPlayer = $ButtonPressSoundFX
@onready var level_select: Control = $LevelSelect

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	ScreenFader.fade_in()
	level_select.connect("selected_level", Callable(self, "level_selected"))

func level_selected(level_name: String):
	ScreenFader.fade_out()
	start_fx.play()
	starting.emit(level_name)
	button_press.play()
	
	await start_fx.finished
	
	queue_free()

func _on_StartButton_button_down():
	level_select.visible = true
	
	#ScreenFader.fade_out()
	#start_fx.play()
	#starting.emit()
	#button_press.play()
	
	#await start_fx.finished
	
	#queue_free()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	button_press.play()
	$Options.visible = true

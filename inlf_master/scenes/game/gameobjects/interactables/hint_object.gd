extends Node3D
class_name HintObject

# automatically toggle the animation player play from here in the baseclass
# locate and set on runtime the reference to the animation player from the baseclass

@export var anim_player: AnimationPlayer

var is_viewing = false
var should_display = true

func _process(_delta):
	if is_viewing:
		if should_display:
			_display_info()
			should_display = false
	else:
		if !should_display:
			_hide_info()
			should_display = true
	is_viewing = false

func _look_at(): #handles info display when being viewed
	is_viewing = true

func _display_info():
	anim_player.play("fade_in")

func _hide_info():
	anim_player.play_backwards("fade_in")

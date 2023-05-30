extends Spatial
class_name HintObject

# automatically toggle the animation player play from here in the baseclass
# locate and set on runtime the reference to the animation player from the baseclass

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

func _display_info(): #overridable method
	pass

func _hide_info(): #overridable method
	pass

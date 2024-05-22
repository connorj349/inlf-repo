extends Spatial

signal magick_changed

const maximum_magick_allowed = 5

var curr_magick = 0 setget set_curr_magick
var max_magick = 0 setget set_max_magick

func init(_max):
	max_magick = _max
	curr_magick = max_magick

func set_curr_magick(val):
	curr_magick = clamp(val, 0, max_magick)
	emit_signal("magick_changed", curr_magick)

func set_max_magick(val):
	max_magick = clamp(val, 0, maximum_magick_allowed)
	if curr_magick > max_magick:
		curr_magick = max_magick

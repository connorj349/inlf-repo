extends Spatial

const maximum_magick_allowed = 5

var curr_magick = 0 # default to 2 always
var max_magick = 0 # default to 2

signal magick_changed

func init(_max): # call this in the player's _ready()
	max_magick = _max
	curr_magick = max_magick

func modify_magick(amount):
	if curr_magick >= amount:
		curr_magick = clamp(curr_magick + amount, 0, max_magick)
		emit_signal("magick_changed", curr_magick)

func increase_max_magick(amount):
	max_magick = clamp(max_magick + amount, 0, maximum_magick_allowed)
	curr_magick = max_magick
	emit_signal("magick_changed", curr_magick)

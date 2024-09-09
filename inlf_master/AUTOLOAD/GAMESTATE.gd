extends Node
## REMOVE THIS SCRIPT
## 
## going to use a different level loading system so that this information is only contained]
## within an individual level instead of in an autoload to prevent confusion/errors

signal bones_changed

var bones: int = 0 :
	set(value):
		bones = clamp(value, 0, 9999)
		emit_signal("bones_changed", bones)
		if value > 0:
			Globals.emit_signal("on_pop_notification", "I received bones.")
		elif value < 0:
			Globals.emit_signal("on_pop_notification", "I have lost bones.")

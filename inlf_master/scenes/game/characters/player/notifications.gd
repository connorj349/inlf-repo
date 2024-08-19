extends Control

const MAX_LINES: int = 5
const DELETE_LINE_AFTER_TIME: float = 4.0

@export var notifications_text: RichTextLabel

var info = []
var remove_info_timer : Timer

func _ready():
	# instead of using Globals, have an autoload that is NotificationPinger that is called from other scripts
	# the notification pinger is then connected to here, similar to how Globals is connected
# warning-ignore:return_value_discarded
	Globals.connect("on_pop_notification", Callable(self, "add_notification"))
	
	remove_info_timer = Timer.new()
	add_child(remove_info_timer)
	remove_info_timer.wait_time = DELETE_LINE_AFTER_TIME
	
# warning-ignore:return_value_discarded
	remove_info_timer.connect("timeout", Callable(self, "remove_notification"))
	
	update_notifications()

func add_notification(text: String):
	remove_info_timer.start()
	
	info.push_back(text)
	
	if info.size() > MAX_LINES:
		info.pop_front()
	
	update_notifications()

func remove_notification():
	if info.size() > 0:
		info.pop_front()
	
	update_notifications()

func update_notifications():
	var _new_text = ""
	
	for text in info:
		_new_text += text + "\n"
	
	notifications_text.text = _new_text

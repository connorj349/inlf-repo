extends Control

const MAX_LINES = 5

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
	remove_info_timer.wait_time = 5.0
# warning-ignore:return_value_discarded
	remove_info_timer.connect("timeout", Callable(self, "remove_notification"))

func add_notification(text):
	remove_info_timer.start()
	
	info.push_back(text)
	
	while info.size() >= MAX_LINES:
		info.pop_front()
	
	update_notifications()

# for some reason the remove_notification isn't working as intended, not sure why
func remove_notification():
	if info.size() > 0:
		info.pop_front()
	
	update_notifications()

func update_notifications():
	notifications_text.text = ""
	
	for text in info:
		notifications_text.append_text(text + "\n")

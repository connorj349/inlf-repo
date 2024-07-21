extends Control

const MAX_LINES = 5

@export var notifications_text: RichTextLabel

var info = []
var remove_info_timer : Timer

func _ready():
# warning-ignore:return_value_discarded
	Globals.connect("on_pop_notification", Callable(self, "add_notification"))
	remove_info_timer = Timer.new()
	remove_info_timer.wait_time = 5.0
# warning-ignore:return_value_discarded
	remove_info_timer.connect("timeout", Callable(self, "remove_notification"))
	add_child(remove_info_timer)

func add_notification(text):
	remove_info_timer.start()
	info.push_back(text)
	while info.size() >= MAX_LINES:
		info.pop_front()
	update_notifications()

func remove_notification():
	if info.size() > 0:
		info.pop_front()
	update_notifications()

func update_notifications():
	notifications_text.text = ""
	for text in info:
		notifications_text.append_text(text + "\n")

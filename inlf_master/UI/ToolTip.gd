class_name ToolTip
extends Node

@export var visuals_res: PackedScene
@export var owner_path: NodePath
@export var delay = 0.5 # (float, 0, 10, 0.05)
@export var follow_mouse: bool = true
@export_range(0, 100, 1.0) var offset_x: float # (float, 0, 100, 1)
@export_range(0, 100, 1.0) var offset_y: float # (float, 0, 100, 1)
@export_range(0, 100, 1.0) var padding_x: float # (float, 0, 100, 1)
@export_range(0, 100, 1.0) var padding_y: float # (float, 0, 100, 1)

@onready var owner_node = get_node(owner_path)
@onready var offset = Vector2(offset_x, offset_y)
@onready var padding = Vector2(padding_x, padding_y)
@onready var extents

var _visuals
var timer

func _ready():
	_visuals = visuals_res.instantiate()
	add_child(_visuals)
	extents = _visuals.size
	owner_node.connect("mouse_entered", Callable(self, "_mouse_entered"))
	owner_node.connect("mouse_exited", Callable(self, "_mouse_exited"))
	_visuals.hide()
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_custom_show"))
# warning-ignore:return_value_discarded
	Globals.connect("on_inventory_toggle", Callable(_visuals, "hide"))

func _process(_delta):
	if _visuals.visible:
		var border = get_viewport().size - padding
		
		var base_position = get_screen_pos()
		var final_x = base_position.x + offset.x
		if final_x + extents.x > border.x:
			final_x = base_position.x - offset.x - extents.x
		var final_y = base_position.y - extents.y - offset.y
		if final_y < padding.y:
			final_y = base_position.y + offset.y
		_visuals.position = Vector2(final_x, final_y)

func _mouse_entered():
	timer.start(delay)

func _mouse_exited():
	timer.stop()
	_visuals.hide()

func _custom_show():
	timer.stop()
	_visuals.show()

func get_screen_pos():
	if follow_mouse:
		return get_viewport().get_mouse_position()
	
	var position = Vector2()
	if owner_node is Node2D:
		position = owner_node.get_global_transform_with_canvas().origin
	return position

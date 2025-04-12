extends PlayerBase
class_name PlayerCultist

@export var ritual_circle_damage: Damage

@onready var ritual_cricle_prefab: PackedScene = load("res://scenes/game/gameobjects/dark_altar/ritual_circle.tscn")

func _process(delta):
	super(delta)
	
	if Input.is_action_just_pressed("draw_circle"):
		if health.health > ritual_circle_damage.amount:
			deal_damage(ritual_circle_damage)
			
			Globals.on_pop_notification.emit("You draw a ritual circle")
			
			var new_ritual_cricle = ritual_cricle_prefab.instantiate()
			get_tree().current_scene.game_world.add_child(new_ritual_cricle)
			new_ritual_cricle.global_position = global_position
		else:
			Globals.on_pop_notification.emit("I don't have enough blood to draw a ritual circle")

func on_use_organ(_organ):
	pass

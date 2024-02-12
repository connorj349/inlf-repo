extends Interactable

# horizontal bars
# onready var blood_prog_bar
# onready var water_prog_bar
# onready var fertilizer_prog_bar
# onready var exotic_prog_bar

#vertical bar
# onready var growth_prog_bar

onready var resource_consume_timer = $ResourceConsumeTimer

var blood setget set_blood
var water setget set_water
var fertilizer setget set_fertilizer
var exotic setget set_exotic
var growth setget set_growth

var current_growing_seed_item_data

func _ready():
	pass

func _interact(_actor):
	# deal damage to player, add blood
	pass

func _on_ItemDeposit_body_entered(body):
	# if item is seed, set current_growing_seed_item_data
	# start grow timer
	# start resource consume timer
	# elif item is water/fert/exotic:
		# increase value
	pass

func _on_GrowTimer_timeout():
	# if growth > current_growing_seed_item_data.growth_needed:
		# for item in current_growing_seed_item_data.output_item_data:
			# create item(item)
	# else:
		# explode
	# ResourceConsumeTimer.stop()
	# current_growing_seed_item_data = null
	pass

func _on_ResourceConsumeTimer_timeout():
	# if blood > current_growing_seed_item_data.blood
		# self.blood -= current_growing_seed_item_data.blood
	# else:
		# self.growth -= 1
	# self.water -= current_growing_seed_item_data.water
	# self.fertilizer -= current_growing_seed_item_data.fertilizer
	# self.exotic -= current_growing_seed_item_data.exotic
	pass

func set_blood(value):
	blood = clamp(value, 0, 100)
	# blood_prog_bar.update_bar(blood)

func set_water(value):
	water = clamp(value, 0, 100)
	# water_prog_bar.update_bar(water)

func set_fertilizer(value):
	fertilizer = clamp(value, 0, 100)
	# fertilizer_prog_bar.update_bar(fertilizer)

func set_exotic(value):
	exotic = clamp(value, 0, 100)
	# exotic_prog_bar.update_bar(exotic)

func set_growth(value):
	growth = clamp(value, 0, 100)
	# growth_prog_bar.update_bar(growth)

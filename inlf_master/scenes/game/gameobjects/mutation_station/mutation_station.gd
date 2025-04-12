extends Interactable

@export var mutations: Array[Mutation]

var level

@onready var menu: PanelContainer = $CanvasLayer/MutationMenu
@onready var stem_cells_count: Label = $CanvasLayer/MutationMenu/MarginContainer/VBoxContainer/RemainingStemCells
@onready var button_list: VBoxContainer = $CanvasLayer/MutationMenu/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer

func _ready():
	menu.connect("visibility_changed", Callable(func():
		if menu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)))
	
	# if the inventory window is toggled, close the mutation station window
	Globals.connect("on_inventory_toggle", Callable(func():
		menu.visible = false))
	
	# need reference to be able to see how many stem cells the player has
	level = get_tree().current_scene.game_world.current_level
	
	level.connect("stem_cells_changed", Callable(func(_count):
		stem_cells_count.text = "current stem cells: " + str(_count)))
	
	# set the text for starting off
	stem_cells_count.text = "current stem cells: " + str(level.player_stem_cells)
	
	populate_mutation_list()

# show the window
func _interact(_actor):
	menu.visible = true

func populate_mutation_list():
	for mutation in mutations:
		var new_button = Button.new()
		button_list.add_child(new_button)
		new_button.icon = mutation.icon
		new_button.text = "%s\n%s\nCost: %s" % [mutation.name, mutation.description, mutation.cost]
		new_button.connect("pressed", Callable(func():
			if mutation in Globals.current_player.purchased_mutations:
				Globals.on_pop_notification.emit("I already have this mutation.")
			else:
				if level.player_stem_cells >= mutation.cost:
					level.player_stem_cells -= mutation.cost
					Globals.current_player.purchased_mutations.append(mutation)
					mutation.apply(Globals.current_player)
					Globals.on_pop_notification.emit("Gained the mutation %s" % mutation.name)
				else:
					Globals.on_pop_notification.emit("Not enough stem cells for this mutation.")
		))

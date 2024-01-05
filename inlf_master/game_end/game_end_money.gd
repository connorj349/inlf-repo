extends Interactable

export(int) var money_required_to_end_game = 1000

# this will be a physical object/place the player must interact with to end the game
# 	this object needs a collision shape/model
# the rot_gameover will be an ending that is 'triggered' when rot reaches max

func _ready():
	pass # display notification that the player can win the game with enough money in chatbox

func _interact(_actor):
	if Gamestate.can_afford(money_required_to_end_game):
		pass # end the game
		# change level back to main screen
		# award stem cells?

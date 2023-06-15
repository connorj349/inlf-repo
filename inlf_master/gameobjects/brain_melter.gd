extends HintObject

# when rot reaches 100, a spawner will spawn the dementia
# on detection of the dementia, swap scenes/end the game

func _on_Area_body_entered(body):
	if body: # if the dementia enters the area, change scenes
		# when the dementia reaches the brain melter, kill the player and
		# kill all npcs, wait a second, then load back to main menu
		# changeup loading screen appearance when loading back to the main menu
		$LoadingScreen.change_scene("res://scenes/Menu.tscn")

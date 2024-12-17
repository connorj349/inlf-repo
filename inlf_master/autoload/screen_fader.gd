extends CanvasModulate
## Screen Fader
##
## Globally accessible object that will fadein/fadeout the entire screen to simulate level changes
## requires that a canvas item be present like TextureRect to cover the screen

signal faded_out
signal faded_in

## public methods

func fade_out():
	$FadePlayer.play("fade_out")
	await $FadePlayer.animation_finished
	faded_out.emit()

func fade_in():
	$FadePlayer.play("fade_in")
	await $FadePlayer.animation_finished
	faded_in.emit()

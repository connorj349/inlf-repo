extends CanvasModulate

signal faded_out
signal faded_in

func fade_out():
	$FadePlayer.play("fade_out")
	await $FadePlayer.animation_finished
	faded_out.emit()

func fade_in():
	$FadePlayer.play("fade_in")
	await $FadePlayer.animation_finished
	faded_in.emit()

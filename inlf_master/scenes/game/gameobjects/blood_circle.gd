extends Interactable

func _ready():
# warning-ignore:return_value_discarded
	Globals.connect("cast_spell", Callable(self, "_cast_spell"))
	anim_player.play("RESET")
	anim_player.seek(0, true)

func _interact(_actor):
	Globals.emit_signal("on_pop_notification", "Consume organs to cast spells.")

func _cast_spell(organ): # create the spell effect; effect will immediately fire
	if organ.magic_effect: # prevent errors
		var spell_effect = organ.magic_effect.instantiate()
		get_tree().current_scene.game_world.add_child(spell_effect)
		spell_effect.global_transform.origin = global_transform.origin

func _on_Area_body_exited(body): # cleanup for the blood circle
	Globals.emit_signal("blood_circle_removed")
	queue_free() # replace with a method that plays an effect showing the ritual circle is dissapating

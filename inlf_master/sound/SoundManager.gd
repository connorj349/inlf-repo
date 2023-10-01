extends Node

# only use this for screen space noises(UI, menus, maybe NPC speech, etc.)

var soundqueues_by_name = {}

func _ready():
	# to add a sound queue, do the following:
	# soundqueues_by_name["new_key_name"] = $SoundQueueObjectReference
	soundqueues_by_name["ui_button_press"] = $UI_ButtonPress
	soundqueues_by_name["zone_enter_tone"] = $Zone_EnterTone


# to expose the method for playing a sound, do the following
#func PlayDesiredSound():
	#soundqueues_by_name["sound_name_key"].PlaySound()

func Play_UI_ButtonPress():
	soundqueues_by_name["ui_button_press"].PlaySound()

func Play_ZONE_EnterTone():
	soundqueues_by_name["zone_enter_tone"].PlaySound()

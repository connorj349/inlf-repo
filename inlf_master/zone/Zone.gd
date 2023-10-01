extends Spatial
tool

export(String) var zone_name = ""
export(float) var show_time = 2.0
export(Vector3) var bounds = Vector3(5, 5, 5)

onready var zone_label = $CanvasLayer/Control/background/zone_label
onready var anim_player = $AnimationPlayer

func _ready():
	zone_label.text = zone_name
	anim_player.play("RESET")
	$Area/CollisionShape.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		$Area/CollisionShape.shape.extents = bounds

func _on_Area_body_entered(body): # handle on_enter effects and zone name displaying
	if body == Globals.current_player and !anim_player.is_playing() and !SoundManager.soundqueues_by_name["zone_enter_tone"].audio_stream_players[0].playing:
		SoundManager.Play_ZONE_EnterTone()
		var t = Timer.new()
		t.wait_time = show_time
		t.one_shot = true
		self.add_child(t)
		t.start()
		anim_player.play("show")
		yield(t, "timeout")
		anim_player.play_backwards("show")

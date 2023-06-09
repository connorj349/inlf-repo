extends Spatial
tool

export(String) var zone_name = ""
export(float) var show_time = 2
export(int) var rot_percentage_needed_to_infect = 50
export(float) var chance_to_infect = 0.8 # 0.8 is 80% chance to infect
export(Vector3) var bounds = Vector3(5, 5, 5)
export(float) var try_infection_frequency = 60

onready var zone_label = $CanvasLayer/Control/background/zone_label
onready var anim_player = $AnimationPlayer
onready var enter_area_sound = $AudioStreamPlayer

signal area_infected

func _ready():
	zone_label.text = zone_name
	anim_player.play("RESET")
	randomize()
	$Timer.wait_time = try_infection_frequency
	$Area/CollisionShape.shape.extents = bounds

func _process(_delta):
	if Engine.is_editor_hint():
		$Area/CollisionShape.shape.extents = bounds

func try_infect():
	if Gamestate.rot >= rot_percentage_needed_to_infect:
		if chance_to_infect == 1: # if chance set to 1, always infect at this percentage
			emit_signal("area_infected")
			return
		var random_hit_result = randf()
		if random_hit_result < chance_to_infect:
			emit_signal("area_infected")

func _on_Area_body_entered(body): # handle on_enter effects and zone name displaying
	if body == Globals.current_player and !anim_player.is_playing() and !enter_area_sound.playing:
		enter_area_sound.play()
		var t = Timer.new()
		t.wait_time = show_time
		t.one_shot = true
		self.add_child(t)
		t.start()
		anim_player.play("show")
		yield(t, "timeout")
		anim_player.play_backwards("show")

func _on_Timer_timeout():
	try_infect()

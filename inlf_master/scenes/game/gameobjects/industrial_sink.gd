extends Interactable

@export var water_item_data: ItemData

var is_broken = false: set = set_is_broken
var health = 100

@onready var use_sound: AudioStreamPlayer3D = $UseSound

func _ready():
	randomize()

func _interact(_actor):
	if !is_broken:
		var new_item = SlotData.new()
		new_item.item_data = water_item_data
		Globals.create_pickup(new_item, $SpawnPoint)
		
		# implement this only for world sinks that the player can drink from
		#health = clamp(health - 10, 0, 100)
		use_sound.play()
		
		# not currently implemented
		if health <= 0:
			self.is_broken = true
			$BreakSound.play()
	else:
		var random_hit_result = randf()
		if random_hit_result < 0.8:
			var _damage = Damage.new()
			_damage.amount = 2
			Globals.current_player.deal_damage(_damage)
		elif random_hit_result < 0.95: #15% chance of being returned
			health = 100
			self.is_broken = false

func set_is_broken(value):
	is_broken = value
	if is_broken:
		$CanvasLayer/Control/VBoxContainer/ActionLabel.text = "this sink is broken\nattempt to repair by using it"
	else:
		$CanvasLayer/Control/VBoxContainer/ActionLabel.text = "use sink to gather dirty water"

extends Spatial

# update how being able to equip weapon works

onready var weapons = get_children()
onready var fists = $wep_fists

var curr_slot = 0
var curr_weapon = null

func _ready():
	fists.is_owned = true #sets fists to always being active
	switch_to_weapon_slot(0)

func attack():
	#check ammo if not melee
	if curr_weapon:
		curr_weapon.on_attack()

func enable_weapon(item_id): #change this to SlotData instead
	for weapon in weapons:
		if weapon.weapon_item_id == item_id:
			weapon.is_owned = true

func switch_to_next_weapon():
	curr_slot = (curr_slot + 1) % weapons.size()
	if !weapons[curr_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(curr_slot)
		#play weapon switch sounds

func switch_to_weapon_slot(slot_id: int):
	if !weapons[slot_id].is_owned:
		switch_to_next_weapon()
		return
	if slot_id < 0 or slot_id >= weapons.size():
		return
	if !weapons[slot_id]:
		return
	disable_all_weapons()
	curr_weapon = weapons[slot_id]
	curr_weapon.show()

func disable_all_weapons():
	for weapon in weapons:
		weapon.hide()

extends Spatial

onready var weapons = get_children() #represents all weapons that can exist on player
onready var fists = $wep_fists #starting weapon

var curr_slot = 0
var curr_weapon = null

func _ready():
	switch_to_weapon_slot(0) #default setup

func attack():
	if curr_weapon:
		if curr_weapon.ammo > 0 or curr_weapon.is_melee:
			curr_weapon.on_attack()

func reload():
	if curr_weapon != fists or !curr_weapon.is_melee:
		curr_weapon.reload(Gamestate.player_inventory) # pass the player's inventory to look for ammo, maybe change to ammo pouch inventory?

func switch_to_next_weapon():
	if !curr_weapon.anim_player.is_playing():
		curr_slot = (curr_slot + 1) % weapons.size()
		if !weapons[curr_slot]:
			switch_to_next_weapon()
		else:
			switch_to_weapon_slot(curr_slot)
			#play weapon switch sounds

func switch_to_weapon_slot(slot_id: int):
	if !Gamestate.weapon_player_inventory.slot_datas[0] or weapons[slot_id] == fists: # if the player has no weapon equipped or they are switching to fists, switch to fists
		disable_all_weapons()
		curr_weapon = fists #equip fists
		curr_weapon.show()
		return
	if weapons[slot_id].item_weapon_data != Gamestate.weapon_player_inventory.slot_datas[0].item_data: # if the weapon's data doesn't match the player's weapon's data, discontinue
		return
	if !weapons[slot_id]: #if a weapon doesn't exist dont continue
		return
	disable_all_weapons()
	curr_weapon = weapons[slot_id]
	curr_weapon.show()

func disable_all_weapons(): #hides visual elements of all weapons
	for weapon in weapons:
		weapon.hide()

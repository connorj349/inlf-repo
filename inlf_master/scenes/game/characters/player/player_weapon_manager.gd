extends Node3D

var curr_slot = 0
var curr_weapon = null

@onready var weapons = get_children() # represents all weapons that can exist on player
@onready var fists = $wep_fists # starting weapon

func _ready():
	switch_to_weapon_slot(0) # default setup
	
	# prevents player from taking weapon out of slot and still being able to use it
	$"../../../../..".weapon_inventory_data.connect("inventory_updated", Callable(self, "switch_to_next_weapon").unbind(1))

func attack():
	if curr_weapon:
		if curr_weapon.ammo > 0 or curr_weapon.is_melee:
			curr_weapon.on_attack()

func reload():
	if curr_weapon != fists or !curr_weapon.is_melee:
		curr_weapon.reload($"../../../../..".inventory_data) # pass the player's inventory to look for ammo, maybe change to ammo pouch inventory?

func switch_to_next_weapon():
	if !curr_weapon.anim_player.is_playing():
		curr_slot = (curr_slot + 1) % weapons.size()
		
		if !weapons[curr_slot]:
			switch_to_next_weapon()
		else:
			switch_to_weapon_slot(curr_slot)
			$"../../../../../Sounds/WeaponSwitchSound".play()

func switch_to_weapon_slot(slot_id: int):
	# if the player has no weapon equipped or they are switching to fists, switch to fists
	if !$"../../../../..".weapon_inventory_data.slot_datas[0] or weapons[slot_id] == fists:
		disable_all_weapons()
		
		curr_weapon = fists # equip fists
		curr_weapon.toggle_visibility(true)
		#curr_weapon.anim_player.play("unholster")
		return
	
	#curr_weapon.anim_player.play_backwards("unholster")
	
	#await(curr_weapon.anim_player.animation_finished)
	
	# DOES NOT ALLOW PLAYER TO SWITCH TO SECONDARY WEAPON; MUST BE REDONE
	# removing this allows the player to switch to weapons they don't actually have
	#if weapons[slot_id].item_weapon_data != $"../../../../..".weapon_inventory_data.slot_datas[0].item_data:
		#return
	
	for _weapon_item_data in $"../../../../..".weapon_inventory_data.slot_datas:
		if weapons[slot_id].item_weapon_data != _weapon_item_data:
			return
	
	# if a weapon doesn't exist dont continue
	if !weapons[slot_id]:
		return
	
	disable_all_weapons()
	
	curr_weapon = weapons[slot_id]
	curr_weapon.toggle_visibility(true)
	
	#curr_weapon.anim_player.play("unholster")

func disable_all_weapons(): # hides visual elements of all weapons
	for weapon in weapons:
		weapon.toggle_visibility(false)

extends Panel

var selectedplanet = 0
onready var Faction_tab = get_node("..")
var mechcost = 4
var amechcost = 8
var mmechcost = 8




func _on_bt_mech_pressed():
	if Input.is_key_pressed(KEY_SHIFT):
		for i in range(5):
			selectedplanet = Faction_tab.selectedplanet
			var factionname = selectedplanet["faction"]
			var faction = gamestate.factions[factionname]
			
			if faction["mass"] >= mechcost:
				faction["mass"] = faction["mass"] - mechcost
				selectedplanet["army"]["mechs"] = selectedplanet["army"]["mechs"] + 1
				selectedplanet["nodeid"].update_planet_info()
				update_recruitment_panel()
	
	else:
		selectedplanet = Faction_tab.selectedplanet
		var factionname = selectedplanet["faction"]
		var faction = gamestate.factions[factionname]
		
		if faction["mass"] >= mechcost:
			faction["mass"] = faction["mass"] - mechcost
			selectedplanet["army"]["mechs"] = selectedplanet["army"]["mechs"] + 1
			selectedplanet["nodeid"].update_planet_info()
			update_recruitment_panel()
		
		
func update_recruitment_panel():
	selectedplanet = Faction_tab.selectedplanet
	var factionname = selectedplanet["faction"]
	var faction = gamestate.factions[factionname]
	
	$mechs.text = str(selectedplanet["army"]["mechs"])
	$amechs.text = str(selectedplanet["army"]["amechs"])
	$mmechs.text = str(selectedplanet["army"]["mmechs"])
	$mechs/Label.text = str(mechcost)
	$amechs/Label.text = str(amechcost)
	$mmechs/Label.text = str(mmechcost)
	$bt_mech.modulate = Color(faction["char_color"])
	$bt_amech.modulate = Color(faction["char_color"])
	$bt_mmech.modulate = Color(faction["char_color"])





	
func _on_bt_amech_pressed():
	if Input.is_key_pressed(KEY_SHIFT):
		for i in range(5):
			selectedplanet = Faction_tab.selectedplanet
			var factionname = selectedplanet["faction"]
			var faction = gamestate.factions[factionname]
			
			if faction["mass"] >= amechcost:
				faction["mass"] = faction["mass"] - amechcost
				selectedplanet["army"]["amechs"] = selectedplanet["army"]["amechs"] + 1
				selectedplanet["nodeid"].update_planet_info()
				update_recruitment_panel()
				
	else:
		selectedplanet = Faction_tab.selectedplanet
		var factionname = selectedplanet["faction"]
		var faction = gamestate.factions[factionname]
		
		if faction["mass"] >= amechcost:
			faction["mass"] = faction["mass"] - amechcost
			selectedplanet["army"]["amechs"] = selectedplanet["army"]["amechs"] + 1
			selectedplanet["nodeid"].update_planet_info()
			update_recruitment_panel()


func _on_bt_mmech_pressed():
	if Input.is_key_pressed(KEY_SHIFT):
		for i in range(5):
			selectedplanet = Faction_tab.selectedplanet
			var factionname = selectedplanet["faction"]
			var faction = gamestate.factions[factionname]
			
			if faction["mass"] >= mmechcost:
				faction["mass"] = faction["mass"] - mmechcost
				selectedplanet["army"]["mmechs"] = selectedplanet["army"]["mmechs"] + 1
				selectedplanet["nodeid"].update_planet_info()
				update_recruitment_panel()
				
	else:
		selectedplanet = Faction_tab.selectedplanet
		var factionname = selectedplanet["faction"]
		var faction = gamestate.factions[factionname]
		
		if faction["mass"] >= mmechcost:
			faction["mass"] = faction["mass"] - mmechcost
			selectedplanet["army"]["mmechs"] = selectedplanet["army"]["mmechs"] + 1
			selectedplanet["nodeid"].update_planet_info()
			update_recruitment_panel()


func _on_Main_unselect():
	hide()

extends Panel
var repaircost = 0
var configuration = "none"

onready var Main = get_node("../../../..")
var selectedship = {"launched":"fake"}
var components = []
onready var faction_menu = get_node("..")
onready var component_asset = preload("res://design_comp.tscn")
#onready var gamestate.player_info.name = gamestate.player_info.name
#onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]

func _ready():
	self.hide()
	

func _on_item_selected(index2):
	update_ship_display()

func update_ship_display():
		# Clear components
	for i in $Design.get_children():
		if i.get_name() != "Sprite":
			i.queue_free()
	components = []
	$Design.hide()
	
	
	
	if selectedship["launched"] == "home":
		# Set repair cost
		configuration = selectedship["configuration"]
		var repairparts = 0
		var parts = 0
		for i in configuration["components"]:
			parts = parts + 1
			if i[3] == "destroyed":
				repairparts = repairparts + 1
		
		repaircost = int((repairparts*configuration["cost"]/parts))
			
				
		if gamestate.factions[gamestate.player_info.name]["mass"] < repaircost:
			$Apply.modulate = Color(0.5,0.5,0.5,1)
		else:
			$Apply.modulate = Color(1,1,1,1)
			
		# Set blueprint
		var blueprint = Main.get_node("designdata").blueprints[configuration["blueprint"]]
		$Design/Sprite.texture = load(blueprint["texture"])
		$Design.show()
		
		# Update labels
		if selectedship["stance"] == "active":
			$orbitlevel.set_pressed(false)
		else:
			$orbitlevel.set_pressed(true)
			
		$Cost.text = str(repaircost)
		$Label.text = selectedship["name"]
		if repaircost == 0:
			$Cost.hide()
			$Box.hide()
		else:
			$Cost.show()
			$Box.show()
		
		
		
		# Load components from blueprint
		for i in blueprint["components"]:
			var component = component_asset.instance()
			components.append(component)
			component.rect_position = Vector2(i[1],i[2]) 
			get_node("Design").add_child(component)
				
		var index2 = 0
		for l in configuration["components"]:
			components[index2].get_node("Sprite").texture = load("res://Components/" + l[0] + ".png")
			components[index2].component = l[0]
			components[index2].rect_rotation = l[4]
			
			if l[3] == "2mechs":
				components[index2].get_node("Sprite").texture = load("res://Components/2mechs.png")
				components[index2].modulate = gamestate.factions[gamestate.player_info.name]["char_color"]
			elif l[3] == "mech":
				components[index2].get_node("Sprite").texture = load("res://Components/mech.png")
				components[index2].modulate = gamestate.factions[gamestate.player_info.name]["char_color"]
			elif l[3] == "amech":
				components[index2].get_node("Sprite").texture = load("res://Components/amech.png")
				components[index2].modulate = gamestate.factions[gamestate.player_info.name]["char_color"]
			elif l[3] == "mmech":
				components[index2].get_node("Sprite").texture = load("res://Components/mmech.png")
				components[index2].modulate = gamestate.factions[gamestate.player_info.name]["char_color"]
			
				
	

			if l[3] == "destroyed":
				components[index2].get_node("Sprite").modulate = Color(1,0.3,0.3,1)
			index2 = index2 + 1
		
			
		
	var mechs = str(faction_menu.selectedplanet["army"]["mechs"])
	var amechs = str(faction_menu.selectedplanet["army"]["amechs"])
	var mmechs = str(faction_menu.selectedplanet["army"]["mmechs"])
	faction_menu.selectedplanet["nodeid"].get_node("C/Army").text = ( mechs + "/" + amechs + "/" + mmechs)
	if int(mechs) + int(amechs) + int(mmechs) > 0:
		faction_menu.selectedplanet["nodeid"].get_node("C/Army").show()
	else:
		faction_menu.selectedplanet["nodeid"].get_node("C/Army").hide()
	$mechs.text = str(faction_menu.selectedplanet["army"]["mechs"])
	$amechs.text = str(faction_menu.selectedplanet["army"]["amechs"])
	$mmechs.text = str(faction_menu.selectedplanet["army"]["mmechs"])
	$mechsprite.modulate = Color(gamestate.factions[gamestate.player_info.name]["char_color"])
	$amechsprite.modulate = Color(gamestate.factions[gamestate.player_info.name]["char_color"])
	$mmechsprite.modulate = Color(gamestate.factions[gamestate.player_info.name]["char_color"])
	

	
	

	
		
	
	



func _on_Apply_pressed():
	if gamestate.factions[gamestate.player_info.name]["mass"] >= repaircost:
		for i in selectedship["configuration"]["components"]:
			if i[3] == "destroyed":
				i[3] = "ready"
		gamestate.factions[gamestate.player_info.name]["mass"] = gamestate.factions[gamestate.player_info.name]["mass"] - repaircost	
	update_ship_display()
	
	

func _on_Main_unselect():
	hide()
	

func _on_bt_mech_pressed():
	var mech = 0
	var empty = 0
	if selectedship.has("location"):
		for i in selectedship["configuration"]["components"]:
			if i[0] == "storage" and i[3] == "mech":
				mech = 1
			elif i[0] == "storage" and i[3] == "ready":
				empty = 1
				
		if mech == 1 and faction_menu.selectedplanet["army"]["mechs"] > 0:
			var index = 1
			for i in selectedship["configuration"]["components"]:
				if i[0] == "storage" and i[3] == "mech":
					i[3] = "2mechs"
					faction_menu.selectedplanet["army"]["mechs"] = faction_menu.selectedplanet["army"]["mechs"] -1
					update_ship_display()
					if Input.is_key_pressed(KEY_SHIFT):
						_on_bt_mech_pressed()
					return
				else:
					index = index + 1
					
		elif empty == 1 and get_parent().selectedplanet["army"]["mechs"] > 0 :			
			var index = 1
			for i in selectedship["configuration"]["components"]:
				if i[0] == "storage" and i[3] == "ready":
					faction_menu.selectedplanet["army"]["mechs"] = faction_menu.selectedplanet["army"]["mechs"] -1
					i[3] = "mech"
					update_ship_display()
					if Input.is_key_pressed(KEY_SHIFT):
						_on_bt_mech_pressed()
					return
				else:
					index = index + 1
	
func _on_bt_amech_pressed():
	var empty = 0
	if selectedship.has("location"):
		for i in selectedship["configuration"]["components"]:
			if i[0] == "storage" and i[3] == "ready":
				empty = 1
				
		if empty == 1 and faction_menu.selectedplanet["army"]["amechs"] > 0:			
			var index = 1
			for i in selectedship["configuration"]["components"]:
				if i[0] == "storage" and i[3] == "ready":
					faction_menu.selectedplanet["army"]["amechs"] = faction_menu.selectedplanet["army"]["amechs"] -1
					i[3] = "amech"
					update_ship_display()
					if Input.is_key_pressed(KEY_SHIFT):
						_on_bt_amech_pressed()
					return
				else:
					index = index + 1


func _on_bt_mmech_pressed():
	var empty = 0
	if selectedship.has("location"):
		for i in selectedship["configuration"]["components"]:
			if i[0] == "storage" and i[3] == "ready":
				empty = 1
				
		if empty == 1 and faction_menu.selectedplanet["army"]["mmechs"] > 0:			
			var index = 1
			for i in selectedship["configuration"]["components"]:
				if i[0] == "storage" and i[3] == "ready":
					faction_menu.selectedplanet["army"]["mmechs"] = faction_menu.selectedplanet["army"]["mmechs"] -1
					i[3] = "mmech"
					update_ship_display()
					if Input.is_key_pressed(KEY_SHIFT):
						_on_bt_mmech_pressed()
					return
				else:
					index = index + 1
				
	

				

func _on_Unload_pressed():
	for i in selectedship["configuration"]["components"]:
		if i[3] == "mech":
			faction_menu.selectedplanet["army"]["mechs"] = faction_menu.selectedplanet["army"]["mechs"] +1
			i[3] = "ready"
		elif i[3] == "2mechs":
			faction_menu.selectedplanet["army"]["mechs"] = faction_menu.selectedplanet["army"]["mechs"] +2
			i[3] = "ready"
		elif i[3] == "amech":
			faction_menu.selectedplanet["army"]["amechs"] = faction_menu.selectedplanet["army"]["amechs"] +2
			i[3] = "ready"
		elif i[3] == "mmech":
			faction_menu.selectedplanet["army"]["mmechs"] = faction_menu.selectedplanet["army"]["mmechs"] +2
			i[3] = "ready"
	update_ship_display()



func _on_orbitlevel_toggled(button_pressed):
	if selectedship.has("stance"):
		if selectedship["stance"] == "active":
			selectedship["stance"] = "passive"
		else:
			selectedship["stance"] = "active"
		



func _on_bt_cancel_pressed():
	for ship in gamestate.factions[gamestate.player_info.name]["ships"]:
		if ship["location"] == faction_menu.selectedplanet["spaceid"]:
			ship["launched"] = "home"
		get_parent().initialize_planet(faction_menu.selectedplanet["nodeid"])
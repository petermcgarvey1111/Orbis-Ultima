extends Area2D
var visible1 = 0
var destinations = []
var fleet = []
onready var Main = get_node("../..")
onready var planet = get_node("..")

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	if 1 ==1 :
		if mouse_pos.distance_to(get_node("..").position) < 30:
			get_node("../selected").show()
			visible1 = 1
		else:
			if visible1 == 1:
				get_node("../selected").hide()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()
	elif event is InputEventMouseButton \
	and event.button_index == BUTTON_RIGHT \
	and event.is_pressed():
    	self.on_right_click()
		

	
func on_click():
	Main.emit_signal("unselect")
	var faction = gamestate.spaces[get_parent().spaceid]["faction"]
	#if gamestate.spaces[get_parent().spaceid]["faction"] == "none" and gamestate.factions[gamestate.player_info.name]["home"] == 1000 and gamestate.spaces[get_parent().spaceid]["type"] == "Planet" and get_parent().spaceid < 6:
	if gamestate.spaces[get_parent().spaceid]["faction"] == "none" and gamestate.spaces[get_parent().spaceid]["type"] == "Planet" and get_parent().spaceid < 6:
		gamestate.spaces[get_parent().spaceid]["faction"] = gamestate.player_info.name
		gamestate.spaces[get_parent().spaceid]["name"] = gamestate.player_info.name
		
		gamestate.factions[gamestate.player_info.name]["home"] = get_parent().spaceid
		gamestate.spaces[get_parent().spaceid]["nodeid"].update_planet_info()
		Main.broadcast_self()
	
	
				
	if Main.sequence == "orders" and Main.clickstate != "battle":
		
		Main.get_node("Battle").rpc("initialize", get_parent().spaceid)
		gamestate.rpc("update_seed", randf())
	
	elif Main.clickstate == "open"  or Main.clickstate == "empty":
		if gamestate.spaces[get_parent().spaceid]["faction"] == gamestate.player_info.name:
			get_node("../../CanvasLayer/UI/Faction").initialize_planet(planet)	
			Main.clickstate = "open"
		
		
func on_right_click():
	if Main.clickstate != "empty":
		if Main.sequence == "orbits":
			if Main.clickstate != "return_order":
				Main.selectedplanet2 = planet
				var k = get_node("../../CanvasLayer/UI/Faction").check_in_range()
				for i in k:
					if i == planet:
						Main.commit_mission(planet)
						Main.clickstate = "return_order"
						return
						
			elif Main.clickstate == "return_order":
				if Main.clickableplanets.has(planet):
					for i in Main.activefleet:
						i["return"] = planet.spaceid
					Main.clickstate = "open"
					#get_node("../../CanvasLayer/UI/Faction/Launch Menu").update_ship_display()
					get_node("../../CanvasLayer/UI/Faction").initialize_planet(get_node("../../CanvasLayer/UI/Faction").selectedplanet["nodeid"])
					#Main.emit_signal("unselect")
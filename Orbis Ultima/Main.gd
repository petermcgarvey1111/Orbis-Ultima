extends Node2D


#Constants
var center = Vector2(1000,500)
#Gagamestate.player_info.name States
puppet var paused = 1
puppet var cycles =0
var mytimer = 0
var clickstate = "empty"
var genesis = 0
var selectedplanet1 = 999 #Launching from
var selectedplanet2 = 999 #Launching to
var selectedplanet3 = 999 #Returning to
var clickableplanets = [] # General use planets array
var activefleet = []
var turns = 0
var sequence = "orbits"
var fleets = {}

#Gagamestate.player_info.name Settings
var rings = gamestate.rings
var moons = gamestate.moons
var planets = gamestate.planets
var startingplayers = gamestate.startingplayers

var emptyspaces = []
var spaces = []

#Shortcuts
##onready var gamestate.player_info.name = gamestate.player_info.name
##onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]

signal unselect


onready var planet_asset = preload("res://Planet.tscn")
onready var fleet_asset = preload("res://Fleet2.tscn")

func _ready():
	set_process_input(true)
	emit_signal("unselect")
	randomize()
	for i in get_node("designdata").standard_configs:
		
		gamestate.factions[gamestate.player_info.name]["configurations"][i["name"]] = i
		
	
	if (get_tree().is_network_server()):
		var players = gamestate.startingplayers
		for i in range(planets):
			generate_planet()
		if players == 2:
			generate_planet_actual("One", 0, Color(1,1,1,1).to_html())
			generate_planet_actual("Two", 3, Color(1,1,1,1).to_html())
		elif players == 3:
			generate_planet_actual("One", 0, Color(1,1,1,1).to_html())
			generate_planet_actual("Two", 2, Color(1,1,1,1).to_html())
			generate_planet_actual("Three", 4, Color(1,1,1,1).to_html())
		elif players == 4:
			generate_planet_actual("One", 0, Color(1,1,1,1).to_html())
			generate_planet_actual("Two", 1, Color(1,1,1,1).to_html())
			generate_planet_actual("Three", 3, Color(1,1,1,1).to_html())
			generate_planet_actual("Four", 4, Color(1,1,1,1).to_html())
		elif players == 5:
			generate_planet_actual("One", 0, Color(1,1,1,1).to_html())
			generate_planet_actual("Two", 1, Color(1,1,1,1).to_html())
			generate_planet_actual("Three", 3, Color(1,1,1,1).to_html())
			generate_planet_actual("Four", 4, Color(1,1,1,1).to_html())
			generate_planet_actual("Five", 5, Color(1,1,1,1).to_html())
		else:
			generate_planet_actual("One", 0, Color(1,1,1,1).to_html())
			generate_planet_actual("Two", 1, Color(1,1,1,1).to_html())
			generate_planet_actual("Three", 2, Color(1,1,1,1).to_html())
			generate_planet_actual("Four", 3, Color(1,1,1,1).to_html())
			generate_planet_actual("Five", 4, Color(1,1,1,1).to_html())
			generate_planet_actual("Six", 5, Color(1,1,1,1).to_html())
		for i in range(moons):
			_on_gen_moon_pressed()
	
	
	# Connect event handler to the player_list_changed signal
	network.connect("player_list_changed", self, "_on_player_list_changed")
	
	# Update the lblLocalPlayer label widget to display the local player name
	$CanvasLayer/UI/PanelPlayerList/lblLocalPlayer.text = gamestate.player_info.name
	
	

	

func generate_planet():
	if genesis == 0:
		genesis = 1
		for i in rings:
			if i < 104:
				var numspaces = (i +1) * 6 #6 * pow(2 ,i)
				for q in numspaces:
					var arc = 2*PI/numspaces
					generate_space(2*PI/numspaces*q, (i+1)*100, arc, "none")
					
			else:
				var numspaces = 12 * i +12
				for q in numspaces:
					var arc = 2*PI/numspaces
					generate_space(2*PI/numspaces*q, (i+1)*100, arc, "none")
					
			
	
	if get_node("/root/Main/Data").planetnames.size() > 0:
		var numnames = get_node("/root/Main/Data").planetnames.size()
		var namerng = randi() % numnames
		var planetname = get_node("/root/Main/Data").planetnames[namerng]
		
		
		var spaceid = randi() % gamestate.spaces.size()
		
		var col1 = randf() 
		var col2 = randf() 
		var col3 = randf() 
		
		var planetcolor = Color(col1,col2,col3,1)
		
		if gamestate.spaces[spaceid]["type"] == "empty" and spaceid > 5:
			generate_planet_actual(planetname, spaceid, planetcolor.to_html())
			get_node("/root/Main/Data").planetnames.remove(namerng)
		else:
			generate_planet()
			
	
sync func generate_planet_actual(planetname, spaceid, color):
		var whichspace = emptyspaces[spaceid]
		whichspace.get_node("Sprite").texture = load("res://Bodies/planet.png")
		whichspace.add_to_group("Planets")
		whichspace.type = "Planet"
		whichspace.color = color
		whichspace.get_node("Sprite").modulate = color
		gamestate.spaces[spaceid]["color"] = color
		gamestate.spaces[spaceid]["type"] = "Planet"
		gamestate.spaces[spaceid]["name"] = planetname
		gamestate.spaces[spaceid]["army"] = {"mechs":4,"amechs":0,"mmechs":2} 
		whichspace.update_planet_info()
		whichspace.get_node("Sprite").show()
		
		
sync func generate_moon_actual(moonname, spaceid, mass):
		var whichspace = emptyspaces[spaceid]
		whichspace.get_node("C/Name").text = moonname
		whichspace.planetname = moonname
		whichspace.get_node("Sprite").texture = load("res://Bodies/moon.png")
		whichspace.add_to_group("Moons")
		whichspace.type = "Moon"
		
		whichspace.get_node("C/Name").show()
		gamestate.spaces[spaceid]["type"] = "Moon"
		gamestate.spaces[spaceid]["name"] = moonname
		gamestate.spaces[spaceid]["mass"] = mass
		
		whichspace.get_node("Sprite").show()
		whichspace.get_node("C/Name").text = whichspace.get_node("C/Name").text + "[" + str(mass) + "]"
	
sync func generate_space(angle, radius, arc, faction):
	if get_node("/root/Main/Data").planetnames.size() > 0:
		var spawnplanet = planet_asset.instance()
		spawnplanet.radius = radius
		spawnplanet.angle = angle
		spawnplanet.arc = arc
		add_child(spawnplanet)
		emptyspaces.append(spawnplanet)
		spaces.append(spawnplanet)
		spawnplanet.spaceid = emptyspaces.size() - 1
		spawnplanet.get_node("C/Name").text = str(emptyspaces.size()-1)
		spawnplanet.planetname = "Sector " + str(emptyspaces.size()-1)
		#spawnplanet.startangle = angle - (mytimer * arc)/60
		spawnplanet.startangle = angle
		var newspace = {
			"faction":faction,
			"type":"empty",
			"sides":[],
			"spaceid":emptyspaces.size() - 1,
			"name":"Sector " + str(emptyspaces.size()-1),
			"angle":angle,
			"arc":arc,
			"radius":radius,
			"startangle":angle,
			"nodeid":spawnplanet			
		}
		gamestate.spaces.append(newspace)
		
		
func pause_game(message):
	emit_signal("unselect")
	get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").array = []
	get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").clear()
	for i in spaces:
		i.get_node("selectable").hide()
	if paused == 1:
		gamestate.factions[gamestate.player_info.name]["campaign_paused"] = false
		broadcast_self()
		rpc("check_players_ready")
		

sync func check_players_ready():
	
	var moveforward = true
	for i in gamestate.factions.values():
		if i["campaign_paused"] == true:
			moveforward = false
	
	if moveforward == true:
		if sequence == "orbits":
			submit_orders()
		elif sequence == "orders":
			return_ships()
		elif sequence == "return":
			resolve_orbits()
			
		for i in gamestate.factions.values():
			i["campaign_paused"] = true
			




func resolve_turn():
	
	for i in gamestate.spaces:
		i["sides"] =[]
	
	if sequence == "orders":
		for l in gamestate.factions.values():
			for j in l["ships"]:
				if j["launched"] == "launched":
					j["location"] = j["destination"]
					
				gamestate.spaces[j["location"]]["sides"].append(j["faction"])
				if gamestate.spaces[j["location"]]["faction"] != "none":
					gamestate.spaces[j["location"]]["sides"].append(gamestate.spaces[j["location"]]["faction"])
				if gamestate.spaces[j["location"]]["faction"] == "none" and gamestate.spaces[j["location"]]["type"] == "Planet":
					gamestate.spaces[j["location"]]["sides"].append(gamestate.spaces[j["location"]]["faction"])
				

	
	
		
		for i in gamestate.spaces:
			var isconflict = false
			for l in i["sides"]:
				if l != i["sides"][0]:
					isconflict = true
					
			if isconflict == true:
				i["nodeid"].get_node("selectable").modulate = Color(1, 0.5, 0.5, 1)
				i["nodeid"].get_node("selectable").show()	
			else:
				autoresolve_noncombat(i)			
					
	elif sequence == "return":
		for l in gamestate.factions.values():
			for j in l["ships"]:
				if j["launched"] == "returning" :
					j["location"] = j["return"]
					unload_passengers(j)
					j["destination"] = -1
					j["return"] = -1
					j["launched"] = "home"
					fleets[j["faction"] + j["name"]].queue_free()
					fleets.erase(j["faction"] + j["name"])
					j.erase("fleet")
				if j["launched"] == "home":
					for i in j["configuration"]["components"]:
						if i[0] == "bombs":
							i[2] = 2
						elif i[0] == "missile":
							i[2] = 1
		
		
		clickstate = "open"

			
	elif sequence == "orbits":
		for i in gamestate.factions.values():
			i["mass"] = i["mass"] + 18
		
			
			
	
		

sync func broadcast_self():
	gamestate.player_info.name = gamestate.player_info.name
	gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]
	rpc("updateplayer", gamestate.player_info.name, gamestate.factions[gamestate.player_info.name])
	for i in gamestate.spaces:
		if i["faction"] == gamestate.player_info.name:
			var dict = i["army"]
			rpc("updaterecruitment", i["spaceid"], dict, gamestate.factions[gamestate.player_info.name])
	
	
			

sync func updateplayer(selfname, data):
	gamestate.factions[selfname] = data
	gamestate.orderedfactions = []
	for i in gamestate.factions.values():
		gamestate.orderedfactions.append(i["name"])
	gamestate.orderedfactions.sort()
	
			
remote func updaterecruitment(planet, dict, player_faction):
	gamestate.spaces[planet]["army"] = dict
	if planet == player_faction["home"]:
		gamestate.spaces[planet]["faction"] = player_faction["name"]
		#gamestate.spaces[planet]["nodeid"].modulate = Color(player_faction["char_color"])
	gamestate.spaces[planet]["nodeid"].update_planet_info()
	
		

sync func submit_orders():
	
	sequence = "orders"
	paused = 0
	cycles = 0
	$CanvasLayer/UI/Panel/Pause.text = "Return"
	for i in gamestate.spaces:
		i["nodeid"].update_planet_info()
	
	gamestate.orderedfactions = []
	for i in gamestate.factions.values():
		gamestate.orderedfactions.append(i["name"])
	gamestate.orderedfactions.sort()
			
	for i in gamestate.orderedfactions:
			for u in gamestate.factions[i]["ships"]:
				if fleets.has(u["faction"] + u["name"]):
					pass
					
				elif u["launched"] == "launched":
					var spawnfleet = fleet_asset.instance()
					var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction": u["faction"]}
					spawnfleet.color = gamestate.factions[i]["char_color"]
					spawnfleet.dictionary = dictionary
					var fleetkey = u["faction"] + u["name"]
					fleets[fleetkey] = spawnfleet
					add_child(spawnfleet)
					
	

sync func return_ships():
	sequence = "return"
	paused = 0
	cycles = 0
	endoforders()
	$CanvasLayer/UI/Panel/Pause.text = "Rotate Orbits"
	
sync func resolve_orbits():
	sequence = "orbits"
	paused = 0
	cycles = 0
	turns = turns + 1
	$CanvasLayer/UI/Panel/Pause.text = "Submit"
	
func endoforders():
	for i in gamestate.factions.values():
		for u in i["ships"]:
			
			if u["launched"] == "home":
				if gamestate.spaces[u["location"]]["faction"] != u["faction"]:
					u["launched"] = "launched"
					u["destination"] = u["location"]
					u["return"] = u["location"]
					var spawnfleet = fleet_asset.instance()
					var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
					spawnfleet.color = gamestate.factions[i["name"]]["char_color"]
					spawnfleet.dictionary = dictionary
					var fleetkey = u["faction"] + u["name"]
					fleets[fleetkey] = spawnfleet
					add_child(spawnfleet)
			
			if u["launched"] == "launched":
				
				for x in u["configuration"]["components"]:
						if x[0] == "booster":
							x[3] = "destroyed"
				
				
				var array = [u]
				var maxrange = getleastrange(array)
				var options = get_destinations_in_dist(gamestate.spaces[u["location"]]["nodeid"], maxrange)
				
				if u.has("towed"):
					options = get_destinations_in_dist(gamestate.spaces[u["location"]]["nodeid"], u["towed"][0])
					u["return"] = u["towed"][1]
					u.erase("towed")
					u["launched"] = "returning"
					
				if options[0].has(gamestate.spaces[u["return"]]["nodeid"]) and gamestate.spaces[u["return"]]["faction"] == u["faction"]:
					u["location"] = u["return"]
					u["launched"] = "returning"
					var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
					fleets[u["faction"] + u["name"]].dictionary = dictionary
					
					
					
				else:
					var found = false
					for i in options[0]:
						if gamestate.spaces[i.spaceid]["faction"] == u["faction"]:
							u["location"] = i["spaceid"]
							u["return"] = i["spaceid"]
							u["launched"] = "returning"
							var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
							fleets[u["faction"] + u["name"]].dictionary = dictionary
							found = true
					if found == false:	
						u["return"] = u["location"]
						u["destination"] = u["location"]
#						var fleets = get_tree().get_nodes_in_group("fleets")
						var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
						fleets[u["faction"] + u["name"]].dictionary = dictionary
			
			
							
			

func _process(delta):
	if paused == 0:
		if sequence == "orbits":
			mytimer = mytimer + 1
		cycles = cycles + 1
		if cycles > 59:
			resolve_turn()
			paused = 1
			if sequence == "return":
				#gamestate.factions[gamestate.player_info.name]["campaign_paused"] = false
				for i in gamestate.factions.values():
					i["campaign_paused"] = false
				rpc("check_players_ready")
		
func _on_player_list_changed():
	# First remove all children from the boxList widget
	for c in $CanvasLayer/UI/PanelPlayerList/boxList.get_children():
		c.queue_free()
	
	# Now iterate through the player list creating a new entry into the boxList
	for p in network.players:
		if (p != gamestate.player_info.net_id):
			var nlabel = Label.new()
			nlabel.text = network.players[p].name
			$CanvasLayer/UI/PanelPlayerList/boxList.add_child(nlabel)
			
func synchronize(id):
	
	
	var array = gamestate.spaces
	for space in array:
		rpc_id(id, "generate_space",space["angle"], space["radius"], space["arc"], space["faction"])
		if space["type"] == "Planet":
			rpc_id(id, "generate_planet_actual",space["name"], space["spaceid"] , space["nodeid"]["color"])
		elif space["type"] == "Moon":
			rpc_id(id, "generate_moon_actual",space["name"], space["spaceid"], space["mass"])
	
	for i in gamestate.factions.values():
		rpc("updateplayer", i["name"], i)
		for l in gamestate.spaces:
			if l["faction"] == i["name"]:
				var dict = l["army"]
				rpc("updaterecruitment", l["spaceid"], dict, i)
	
	
	
	
	rpc_id(id,"pass_info",mytimer, gamestate.startingmass, sequence)			
	rpc_id(id, "broadcast_self")	
	
func synchronize_all():
	
	rpc("pass_info",mytimer, gamestate.startingmass, sequence)
	var array = gamestate.spacessaved
	for space in array:
		rpc("generate_space",space["angle"], space["radius"], space["arc"], space["faction"])
		
	for space in array:	
		if space["type"] == "Planet":
			rpc("generate_planet_actual",space["name"], space["spaceid"] , space["color"])
		elif space["type"] == "Moon":
			rpc("generate_moon_actual",space["name"], space["spaceid"], space["mass"])
	




				
func get_destinations_in_dist(spaceidd, dist):
	var destinations = [spaceidd]
	var toremove = []
	var intemediates2 = []
	var intemediates = [spaceidd]
	var spacestotry = spaces.duplicate()
	for i in dist:
		
		for spaceid in intemediates:
			for space in spacestotry:
				
				if spaceid == space:
					intemediates2.append(space)
					toremove.append(space)
					
					
				elif space.radius == spaceid.radius or space.radius == spaceid.radius - 100:
					var angle1 = (center - space.position).normalized()
					var angle2 = (center - spaceid.position).normalized()
					var anglebetween = acos(angle1.dot(angle2))
					if abs(anglebetween)  < spaceid.arc + 0.02:
					
						
						intemediates2.append(space)
						toremove.append(space)
					
				elif space.radius == spaceid.radius + 100:
					var angle1 = (center - space.position).normalized()
					var angle2 = (center - spaceid.position).normalized()
					var anglebetween = acos(angle1.dot(angle2))
					
					
					if abs(anglebetween)  < space.arc + 0.02:
						
						intemediates2.append(space)
						toremove.append(space)
				else:
					pass
			for k in toremove:
				spacestotry.erase(k)
			toremove = []
			
			toremove.append(spaceid)
		for k in toremove:
				intemediates.erase(k)
				toremove = []
		intemediates = intemediates2
		destinations = intemediates + destinations
		for i in destinations:
			pass
		intemediates2 = []	
	return [destinations]
		
func getleastrange(fleet):
	if fleet.size() > 0:
		var maxrange = 100
		for i in fleet:
			var engines = 0
			for l in i["configuration"]["components"]:
				if l[0] == "engine" and l[3] == "ready":
					engines = engines + 1
				elif l[0] == "booster" and l[3] == "ready":
					engines = engines + 1
			if engines < maxrange:
				maxrange = engines
		return maxrange
	else:
		return 0
		
func getrange(ship):
	var engines = 0
	for l in ship["configuration"]["components"]:
			if l[0] == "engine" and l[3] == "ready":
				engines = engines + 1
			elif l[0] == "booster" and l[3] == "ready":
				engines = engines + 1
	return engines

	
		
remote func pass_info(v_mytimer, startingmass, sequence2):
	mytimer = v_mytimer
	sequence = sequence2
	if gamestate.factions[gamestate.player_info.name]["mass"] == -999:
		gamestate.factions[gamestate.player_info.name]["mass"] = startingmass
	
	for i in fleets.values():
			i.queue_free()
			
	fleets = {}
	
		
	for i in gamestate.factions.values():
		for u in i["ships"]:
			if u["launched"] == "launched":
				var spawnfleet = fleet_asset.instance()
				var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
				spawnfleet.color = gamestate.factions[i["name"]]["char_color"]
				spawnfleet.dictionary = dictionary
				var fleetkey = u["faction"] + u["name"]
				fleets[fleetkey] = spawnfleet
				add_child(spawnfleet)

func _on_Commit_pressed():
	pass

func commit_mission(target):
	var index = get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").get_selected_items()
	var array = get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").array
	activefleet = []
	for i in index:
		activefleet.append(array[i])
	for l in activefleet:
		l["destination"] = target.spaceid
		l["launched"] = "launched"
	get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").clear()
	get_node("CanvasLayer/UI/Faction/Launch Menu/Ship List").array = []
		
	for j in spaces:
			j.get_node("selectable").hide()
	var maxrange = getleastrange(activefleet)
	var possibledestinations = get_destinations_in_dist(selectedplanet2, maxrange)
	clickableplanets = []
	for x in possibledestinations[0]:
		var space = gamestate.spaces[x.spaceid]
		
		if space["type"] == "Planet":
			#if space["faction"] == gamestate.player_info.name:
			x.get_node("selectable").show()
			clickableplanets.append(x)
			
	
					


func _on_gen_moon_pressed():
	if get_node("/root/Main/Data").moonnames.size() > 0:
		var numnames = get_node("/root/Main/Data").moonnames.size()
		var namerng = randi() % numnames
		var moonname = get_node("/root/Main/Data").moonnames[namerng]
		get_node("/root/Main/Data").moonnames.remove(namerng)
		var mass = randi() % 3 + randi() % 3 + randi() % 3 + 1
		var spaceid = randi() % gamestate.spaces.size()
		if gamestate.spaces[spaceid]["type"] == "empty":
			generate_moon_actual(moonname, spaceid, mass)
		else:
			_on_gen_moon_pressed()
		
		
		

func _on_Main_unselect():
	clickstate = "empty"
	selectedplanet1 = 999 #Launching from
	selectedplanet2 = 999 #Launching to
	selectedplanet3 = 999 #Returning to
	for i in gamestate.spaces:
		if i["nodeid"].get_node("selectable").modulate != Color(1, 0.5, 0.5, 1):
			i["nodeid"].get_node("selectable").hide()


func unload_passengers(ship):
	var faction = ship["faction"]
	var spaceid = ship["location"]
	var location = gamestate.spaces[spaceid]
	if location["faction"] == faction:
		
		
		var mass = gamestate.factions[faction]["mass"]
		var mechs = location["army"]["mechs"]
		var amechs = location["army"]["amechs"]
		var mmechs = location["army"]["mmechs"]
		
				
		for i in ship["configuration"]["components"]:
			if i[3] == "mech":
				mechs = mechs + 1
				i[3] = "ready"
			elif i[3] == "2mechs":
				mechs = mechs + 2
				i[3] = "ready"
			elif i[3] == "amech":
				amechs = amechs + 1
				i[3] = "ready"
			elif i[3] == "mmech":
				mmechs = mmechs + 1
				i[3] = "ready"
			elif i[3] == "mass":
				mass = mass + i[2]
				i[3] = "ready"
				i[2] = 0
		
		location["army"]["mechs"] = mechs
		location["army"]["amechs"] = amechs
		location["army"]["mmechs"] = mmechs
		location["nodeid"].update_planet_info()
		gamestate.factions[faction]["mass"] = mass

func autoresolve_noncombat(space):
	var ships = []
	for x in gamestate.orderedfactions:
		for y in gamestate.factions[x]["ships"]:
			if y["location"] == space["spaceid"]:
				ships.append(y)
	
	if space["type"] == "Moon":
		var mass = space["mass"] * 10
		for i in ships:
			for l in i["configuration"]["components"]:
				if mass > 0:
					if l[0] == "storage" and l[3] == "ready": 
						mass = mass - 10
						l[2] = 10
						l[3] = "mass"
			
	
	
func _input(event):
	if event.is_action("test"):
		for i in gamestate.factions.values():
			for l in i["ships"]:
				print(l["launched"])
				print(fleets)
	
	
	
	
	
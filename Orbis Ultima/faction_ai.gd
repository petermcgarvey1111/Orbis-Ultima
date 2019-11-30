extends Node
var initialized = false
onready var faction = {}
onready var faction_name = "ai"
onready var Main = get_parent().get_parent()
var ship_types = {}

var missions_array = []
var fleet_array = []
var committed_missions = []
var my_planets = []
var armies = {}
var escorts = []
var transports = []
var assaulters = []
var danger = {}
var most_turns = 4



func run_ai():
	if initialized == false:
		initialized = true
		populate_real_spaces()
	calculate_danger()
	repair_damage()
	#calculate_ship_classes()
	build_recruit()
	declare_missions()
	committed_missions = []
	
func populate_real_spaces():
	gamestate.realspaces = []
	gamestate.Moons = []
	gamestate.Planets = []
	for i in gamestate.spaces:
		if i["type"] == "Planet" :
			gamestate.realspaces.append(i)
			gamestate.Planets.append(i)
		elif i["type"] == "Moon":
			gamestate.realspaces.append(i)
			gamestate.Moons.append(i)
	
func calculate_danger():
	for i in gamestate.realspaces:
		var enemy = 10.00
		var friend = 10.0
		var number = 0.0
				
		for j in gamestate.Planets:
			if j["faction"] == faction_name and get_distance(i["spaceid"], j["spaceid"]) < friend:
				friend = get_distance(i["spaceid"], j["spaceid"])
				number = 1
			elif j["faction"] == faction_name and get_distance(i["spaceid"], j["spaceid"]) == friend:
				number += 1
			elif j["faction"] != faction_name and j["faction"] != "none" and get_distance(i["spaceid"], j["spaceid"]) < enemy:
				enemy = get_distance(i["spaceid"], j["spaceid"])
		danger[i["spaceid"]] = [(friend + 1)/ (enemy + 1), friend, number]
		
		
		
		
				
				

func calculate_armies(): #TOFIX keys
	armies = []
	for i in gamestate.spaces:
		armies.append(0)
	for i in my_planets:
		armies[i.spaceid] = gamestate.spaces[i.spaceid]["army"]["mechs"] + gamestate.spaces[i.spaceid]["army"]["amechs"] * 2
	
	

func calculate_fleets():
	escorts = []
	assaulters = []
	transports = []
	for i in faction["ships"]:
		if i["launched"] == "home":
			if i["configuration"]["ai"]["ship_class"] == "escort":
				escorts.append(i)
			elif i["configuration"]["ai"]["ship_class"] == "transport":
				transports.append(i)
			elif i["configuration"]["ai"]["ship_class"] == "assault":
				assaulters.append(i)
			else:
				print("nope")
			



	
	
func declare_missions():	
	while planet_pick_mission() == true:
		pass
				

# Head script for picking a mission to use.	
func planet_pick_mission():
#	var available_ships = []
	
	var mission = [1, [], 0, -1]
	
	
	var this_mission = [1, [], 0, -1] # Priority, ships, range?, destinationid
	for j in gamestate.realspaces:  # Iterate over planets/moons in range.
		
		this_mission = [1, [], 0, -1]
		calculate_armies()
		calculate_fleets()
		var available_mass = 0
		var storage_needed = 0 
		var assault_needed = 0
		var mission_type = "none"
		var protection = 0.0
		var assets = 0.0
		
		if committed_missions.has(j["spaceid"]) == false:
			if j["type"] == "Moon": # For moons
				mission_type = "moon"
				available_mass = gamestate.spaces[j["spaceid"]]["mass"]
				storage_needed = available_mass
			elif j["type"] == "Planet" and j["faction"] != faction_name:
				mission_type = "planet"
				var enemy_ground_force = (gamestate.spaces[j["spaceid"]]["army"]["mechs"] + gamestate.spaces[j["spaceid"]]["army"]["amechs"] * 2 + gamestate.spaces[j["spaceid"]]["army"]["mmechs"] * 3) + 2
				assault_needed = enemy_ground_force * 1.3 / 2
				var assault_supplied = 0
						
				
			this_mission[3] = j["spaceid"]
			var storage_cap = 0
			var index2 = 0
			
			
			
			
			
			for x in range(6): # Check what we can provide to this mission.
				for k in assaulters:				
					var ai = k["configuration"]["ai"]
					if ai["range"] == x:
						if get_distance(k["location"], j["spaceid"]) <= ai["range"]:
							if assault_needed > 0:
								this_mission[1].append(k["name"])
								storage_needed -= ai["transport"]
								assault_needed -= ai["assault"]
								protection += ai["escort"]
								assets += ai["assault"]
								if armies[k["location"]] > 0 and armies[k["location"]] > ai["transport"] * 2:
									assault_needed -= ai["transport"]
									armies[j["spaceid"]] -= ai["transport"] * 2
								elif armies[j["spaceid"]] > 0:
									armies[k["location"]] = 0
									assault_needed -= armies[k["location"]]
			
			
				for k in transports:
					var ai = k["configuration"]["ai"]
					if ai["range"] == x:
						
						if get_distance(k["location"], j["spaceid"]) <= ai["range"]:
							
							if storage_needed > 0:
								this_mission[1].append(k["name"])
								storage_needed -= ai["transport"]
								assault_needed -= ai["assault"]
								assault_needed -= ai["transport"]
								assets += ai["transport"]
								protection += ai["escort"]
							elif assault_needed > 0.0:
								if armies[k["location"]] > 0:# and armies[k["location"]] > ai["transport"] * 2:
									this_mission[1].append(k["name"])
									assets += ai["transport"]
									assault_needed -= ai["assault"]
									assault_needed -= ai["transport"]
									armies[k["location"]] -= ai["transport"] * 2
									protection += ai["escort"]
								elif armies[k["location"]] > 0:
									this_mission[1].append(k["name"])
									assets += ai["transport"]
									assault_needed -= ai["assault"]
									armies[k["location"]] = 0
									assault_needed -= armies[k["location"]]
									protection += ai["escort"]
								
								
				for k in escorts:				
					var ai  = k["configuration"]["ai"]
					if ai["range"] == x:
						if get_distance(k["location"], j["spaceid"]) <= ai["range"]:
							if assets * danger[j["spaceid"]][0] > protection and danger[j["spaceid"]][0] > randf():
								this_mission[1].append(k["name"])
								storage_needed -= ai["transport"]
								assault_needed -= ai["assault"]
								protection += ai["escort"]
								
				
						
								
								
								
			if mission_type == "moon":
				var waste = 0
				if storage_needed < 0:
					waste = abs(storage_needed)
					this_mission[0] = 100 * (10 - waste)/10 #Reduce desirability of wasting cargo spaces 	
				else:
					this_mission[0] = 100
					
			elif mission_type == "planet":	
				if assault_needed <= 0:
					this_mission[0] = 100
				
			protection = (protection + 1) / (assets + 1)
			this_mission[0] *= (1/(1 + danger[j["spaceid"]][0]/(protection)))
				
			
			
			
			
			
					
				
			#print(str(this_mission) + " " +j["name"])	
			if this_mission[0] < 20 or this_mission[1].size() == 0:
				committed_missions.append(this_mission[3])		
			elif this_mission[0] > mission[0]:
				mission = this_mission
			
				
				
				
	
			
		
	#print(str(mission) + " This one")
	# Carry out Mission
	if mission[0] != 1:
		committed_missions.append(mission[3])
		for i in faction["ships"]:
			if mission[1].has(i["name"]):
				i["launched"] = "launched"
				i["destination"] = mission[3]
				i["return"] = i["location"]
			#print(gamestate.spaces[mission[3]["spaceid"]]["type"])
				if gamestate.spaces[mission[3]]["type"] == "Planet":
					load_mechs(i)
					i["return"] = mission[3]
		return true
	else:
		return false

	
func load_mechs(ship): # Fills ship with mechs, starting with assault mechs.

	
	for i in ship["configuration"]["components"]:
		if i[0] == "storage" and i[3] == "ready" and gamestate.spaces[ship["location"]]["army"]["amechs"] > 0:
			gamestate.spaces[ship["location"]]["army"]["amechs"] = gamestate.spaces[ship["location"]]["army"]["amechs"] - 1
			i[3] = "amech"

	for i in ship["configuration"]["components"]:
		if i[0] == "storage" and i[3] == "mech" and gamestate.spaces[ship["location"]]["army"]["mechs"] > 0:
			gamestate.spaces[ship["location"]]["army"]["mechs"] = gamestate.spaces[ship["location"]]["army"]["mechs"] - 1
			i[3] = "2mechs"

		elif i[0] == "storage" and i[3] == "ready" and gamestate.spaces[ship["location"]]["army"]["mechs"] > 1:
			gamestate.spaces[ship["location"]]["army"]["mechs"] = gamestate.spaces[ship["location"]]["army"]["mechs"] - 2
			i[3] = "2mechs"

		elif i[0] == "storage" and i[3] == "ready" and gamestate.spaces[ship["location"]]["army"]["mechs"] > 0:
			gamestate.spaces[ship["location"]]["army"]["mechs"] = gamestate.spaces[ship["location"]]["army"]["mechs"] - 1
			i[3] = "mech"

func repair_damage():
	
	for i in faction["ships"]:
		
		if i["launched"] == "home":
			var configuration = i["configuration"]
			var repairparts = 0
			var parts = 0
			
			for i in configuration["components"]:
				parts = parts + 1
				if i[3] == "destroyed":
					repairparts = repairparts + 1
					i[3] = "ready"
			
			faction["mass"] = faction["mass"] - int((repairparts*configuration["cost"]/parts))
	
func build_recruit():
	my_planets = []
	for i in gamestate.realspaces:
		if i["type"] == "Planet":
			if i["faction"] == faction["name"]:
				my_planets.append(i["nodeid"])
				
	for i in my_planets:
		while faction["mass"] > 10:
			if gamestate.spaces[i["spaceid"]]["army"]["mmechs"] < 2:
				faction["mass"] -= 8
				gamestate.spaces[i["spaceid"]]["army"]["mmechs"] += 1
			elif gamestate.spaces[i["spaceid"]]["army"]["mechs"] < 4:
				faction["mass"] -= 4
				gamestate.spaces[i["spaceid"]]["army"]["mechs"] += 1
			else:
				break
				
		
		
	for i in my_planets:
		var planet_fleet = []
		
		for z in range(10):
			planet_fleet.append({
			"escort": 0,
			"transport": 0,
			"assault": 0,
			"tow": 0, 
			})
		
		
		
		for l in faction["ships"]:
			
			if l["location"] == i["spaceid"]:
				planet_fleet[l["configuration"]["ai"]["range"]]["escort"] += l["configuration"]["ai"]["escort"]
				planet_fleet[l["configuration"]["ai"]["range"]]["tow"] += l["configuration"]["ai"]["tow"]
				planet_fleet[l["configuration"]["ai"]["range"]]["transport"] += l["configuration"]["ai"]["transport"]
				planet_fleet[l["configuration"]["ai"]["range"]]["assault"] += l["configuration"]["ai"]["assault"]
				
		
		#for x in range(3):
		for x in gamestate.Moons:
			x = x["spaceid"]
				
			var dist = get_distance(i.spaceid, x)
			if dist == danger[x][1]:	
				
				planet_fleet[dist]["transport"] -= gamestate.spaces[x]["mass"] / danger[x][2]
				planet_fleet[dist]["escort"] -= gamestate.spaces[x]["mass"] / 2 / danger[x][2]
		
		
		
		
		var index = 0	
		for j in planet_fleet:
			for o in range(5):
				if j["transport"] < 0 and j["transport"] <= j["escort"]:
					for k in faction["configurations"].values():
						if k["ai"]["range"] == index:
							if k["ai"]["ship_class"] == "transport" and k["ai"]["transport"] <= abs(j["transport"]):
								if k["cost"] <= faction["mass"]:
									faction["mass"] -= k["cost"]
									buy_ship(k["name"], i)
									planet_fleet[k["ai"]["range"]]["escort"] += k["ai"]["escort"]
									planet_fleet[k["ai"]["range"]]["tow"] += k["ai"]["tow"]
									planet_fleet[k["ai"]["range"]]["transport"] += k["ai"]["transport"]
									planet_fleet[k["ai"]["range"]]["assault"] += k["ai"]["assault"]
									
									
				elif j["escort"] < 0 and j["transport"] > j["escort"]:
					for k in faction["configurations"].values():
						if k["ai"]["range"] == index:
							if k["ai"]["ship_class"] == "escort":
								if k["cost"] <= faction["mass"]:
									faction["mass"] -= k["cost"]
									buy_ship(k["name"], i)
									planet_fleet[k["ai"]["range"]]["escort"] += k["ai"]["escort"]
									planet_fleet[k["ai"]["range"]]["tow"] += k["ai"]["tow"]
									planet_fleet[k["ai"]["range"]]["transport"] += k["ai"]["transport"]
									planet_fleet[k["ai"]["range"]]["assault"] += k["ai"]["assault"]
					
			index += 1
			
		
			
	for i in my_planets:
		while faction["mass"] > 10:
			if gamestate.spaces[i["spaceid"]]["army"]["amechs"] < 4:
				faction["mass"] -= 8
				gamestate.spaces[i["spaceid"]]["army"]["amechs"] += 1
			elif gamestate.spaces[i["spaceid"]]["army"]["mechs"] < 12:
				faction["mass"] -= 4
				gamestate.spaces[i["spaceid"]]["army"]["mechs"] += 1
			else:
				break	
	
	
	for i in my_planets:	
		i.update_planet_info()
	
		
func buy_ship(configuration, planet):
		
	var newship = Main.get_node("designdata").standard_ship.duplicate(true)
	newship["name"] = str(configuration)
	var name_taken = true
	while name_taken == true:
		name_taken = false
		newship["name"] = str(newship["name"] + " ")
		for i in faction["ships"]:
			if i["name"] == newship["name"]:
				name_taken = true
	newship["location"] = planet["spaceid"]
	newship["launched"] = "home"
	newship["faction"] = faction_name
	newship["configuration"] = faction["configurations"][configuration].duplicate(true)
	newship["blueprint"] = newship["configuration"]["blueprint"]
	faction["ships"].append(newship)
	for i in newship["configuration"]["components"]:
		if i[0] == "bombs":
			i[2] = 2
		elif i[0] == "missile":
			i[2] = 1
			
#	for i in faction["ships"]:
#		print(i["configuration"])

func get_distance(planet1, planet2):
	return gamestate.spaces[planet1]["rangetable"][planet2]
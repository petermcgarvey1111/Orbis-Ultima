extends Node2D

var spawnorder = 1000
var unloadradius = 250		#To be able to unload
var turretradius = 420		#Turret spawn
var missileradius = 1000		#Range of missile mechs
var combatradius = 800		#Spawn for close orbit shipsf
var pursuitradius = 1000	#Distance at which you can no longer be attacked
var deepradius = 1600		#Spawn for deep orbit ships
var exitradius = 2000		#Distance for disappearance

var battle_paused = true

onready var mech_asset = preload("res://mech.tscn")
#onready var gamestate.player_info.name = gamestate.player_info.name
#onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]
onready var factions = []
onready var ships = []
onready var ships2 = []
onready var shipnodes = []
onready var ship_asset = preload("res://Ship.tscn")
onready var Main = get_parent()
onready var selectedships = []
var mass = 0
var mechs = []
var location = 999
onready var blueprints = get_node("../designdata").blueprints
var continuoustimer = 0
var battletimer = 0
var nextposition = -PI/2
var core = Vector2(0,0)
var selectedship = 0
var send = 0
var rg = RandomNumberGenerator.new()
var queuedorders = []
var queuedorders2 = []
var physicstimer =0 
var delta2 =  0.01665

var lag_delay = 15

func _ready():
	pass

	
func _physics_process(delta):
#	if Input.is_key_pressed(KEY_X):
#		print(get_global_mouse_position())
	
	
	continuoustimer = continuoustimer + 1
	if battle_paused == false:
		battletimer = battletimer + 1 
		physicstimer = physicstimer + delta
#	print(queuedorders)
#	print(battletimer)	
		
	
	for i in queuedorders2:
		if i[0] == continuoustimer:
			if i[1] == "unpause_game":
				if gamestate.factions[i[2]]["battle_paused"] == true:
					pause_toggle(i[2])
			elif i[1] == "pause_game":
				if gamestate.factions[i[2]]["battle_paused"] == false:
					pause_toggle(i[2])
					

	var keep_going = 1
	while keep_going == 1:
		keep_going = 0
		var index = -1
		for i in queuedorders:
			index = index + 1
			if i[0] == battletimer:
				if i[1] == "pause_game":
					if gamestate.factions[i[2]]["battle_paused"] == false:
						pause_toggle(i[2])
						
						
				elif i[1] == "destroy_comp":
					destroy_comp(i[2], i[3])
				elif i[1] == "burn":
					shipnodes[i[2]].burn(i[3])
				elif i[1] == "combat_travel":
					shipnodes[i[2]].mission = "combat_travel"
					shipnodes[i[2]].get_node("navigation").travel_target = i[3]
					
				elif i[1] == "combat_escort":
					shipnodes[i[2]].mission = "combat_escort"
					shipnodes[i[2]].get_node("navigation").escort_target = shipnodes[i[3]]
					shipnodes[i[2]].get_node("navigation").escort_index = i[4]
				
				elif i[1] == "load":
					shipnodes[i[2]].mission = "load"
					
				elif i[1] == "unload":
					shipnodes[i[2]].mission = "unload"
				
				elif i[1] == "retreat":
					shipnodes[i[2]].mission = "exit"
				
				elif i[1] == "tow":
					shipnodes[i[2]].mission = "tow"
					shipnodes[i[2]].towtarget = shipnodes[i[3]]
					
				elif i[1] == "combat":
					shipnodes[i[2]].mission = "combat"
					
				elif i[1] == "stand":
					shipnodes[i[2]].mission = "stand"
					
					
					
				queuedorders.remove(index)
				keep_going = 1
				break

			
	
func area_selected(obj):
	var start = obj.start
	var end = obj.end
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))	
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))	
	if not Input.is_key_pressed(KEY_SHIFT):
		deselect_all()
	var ut = get_units_in_area(area)
	for u in ut:
		if u.faction == gamestate.player_info.name and u.hulls > 0:
			selectedships.append(u)
			
			
	
func get_units_in_area(area):
	var u = []
	for ship in shipnodes:
		if ship.position.x > area[0].x and ship.position.x < area[1].x:
			if ship.position.y > area[0].y and ship.position.y < area[1].y:
				u.append(ship)
	return u
	
func deselect_all():
	selectedships = []
	
sync func initialize(spaceid):
	print(gamestate.current_seed)
	rg.seed = gamestate.current_seed
	queuedorders = []
	continuoustimer = 0
	battletimer = 0
	mass = 0
	get_parent().sequence = "battle"
	
	
	
	
	location = gamestate.spaces[spaceid]
	$battlefield/Sprite.modulate = Color(gamestate.spaces[spaceid]["nodeid"].color).blend(Color(1,1,1,0.5))
	$battlefield/Sprite.show()
	$CanvasLayer/scene/Node2D/Sprite.show()
	if location["type"] == "Planet":
		$CanvasLayer/scene/Label.text = location["name"]
		$battlefield/Sprite.texture = load("res://Bodies/battlefield2.png")
		if location["faction"] != "none":
			$CanvasLayer/scene/Label.modulate = gamestate.factions[location["faction"]]["char_color"]
		else:
			$CanvasLayer/scene/Label.modulate = Color(1,1,1,1)
	elif location["type"] == "Moon":
		$CanvasLayer/scene/Label.text = location["name"]
		$battlefield/Sprite.texture = load("res://Bodies/battlefield.png")
		
	else:
		$battlefield/Sprite.hide()
		$CanvasLayer/scene/Node2D/Sprite.hide()
		
		
	$background/background.show()
	show()
	$battlefield/mass.hide()
	$battlefield/mass_label.hide()
	get_node("CanvasLayer/scene").show()
	ships = []
	shipnodes = []
	factions = []
	Main.get_node("CanvasLayer/UI").hide()
	Main.clickstate = "battle"
	
	
	factions = []	
	ships2 = []	
	gamestate.orderedfactions = []
	for i in gamestate.factions.values():
		gamestate.orderedfactions.append(i["name"])
	gamestate.orderedfactions.sort()
	for x in gamestate.orderedfactions:
		for y in gamestate.factions[x]["ships"]:
			if y["location"] == spaceid:
				ships2.append(y)
				if factions.has(y["faction"]):
					pass
				else:
					factions.append(y["faction"])
					
	if gamestate.spaces[spaceid]["faction"] != "none":
		if factions.has(gamestate.spaces[spaceid]["faction"]):
			pass
		else:
			factions.append(gamestate.spaces[spaceid]["faction"])
					
	$CanvasLayer/Paused.show()
	battle_paused = true
	
	for i in factions:
		gamestate.factions[i]["battle_paused"] = true
	$CanvasLayer/Paused.update()				
	
	
	var width2 = 0
	var numfactions = factions.size()
	var cur_id = 0
	var numships = ships2.size()
	
		
	var fac_angle = 0
	for l in range(numfactions):
		fac_angle = fac_angle + 2*PI / (numfactions)
		var fac_start = Vector2(cos(fac_angle), sin(fac_angle))
		var fac_angle2 = Vector2(fac_start.y, -fac_start.x)
		if numfactions == 1:
			fac_start = fac_start * 4000
		else:
			fac_start = fac_start * 15000
		nextposition = fac_start
		for i in ships2:
			if i["faction"] == factions[l]:
				var ship = ship_asset.instance()
				if Main.getrange(i) > 0:
					var width = blueprints[i["configuration"]["blueprint"]]["width"]
					nextposition = nextposition +  (width + width2)/2 * 5 * fac_angle2
					width2 = blueprints[i["configuration"]["blueprint"]]["width"]
					ship.startangle = nextposition
					ship.position = nextposition
					ship.rotation = fac_angle + PI
				else:
					var radius = rg.randf() * 48000 + 2000
					var direction = fac_angle + (rg.randf() - 0.5) * PI / numfactions
					ship.rotation = rg.randf() * 2 * PI
					ship.speed = 10
					
					var tetherradius = 10000
					for z in i["configuration"]["components"]:
						if z[0] == "orbital1" and z[3] == "ready" and tetherradius > 800:
							tetherradius = 800
						elif z[0] == "orbital2" and z[3] == "ready" and tetherradius > 2500:
							tetherradius = 2500
						elif z[0] == "orbital3" and z[3] == "ready" and tetherradius > 5000:
							tetherradius = 5000
					if tetherradius < 7000:
						radius = tetherradius
						direction = rg.randf() * 2 * PI
						ship.rotation = direction	
						ship.speed = 0 
					
					
					ship.position = Vector2(cos(direction), sin(direction)) * radius
				
					
					
				
				ship.ship = i
				ship.faction = i["faction"]
				ship.get_node("Label").shipname = i["name"]
				ship.get_node("Label").modulate = gamestate.factions[i["faction"]]["char_color"]
				ship.get_node("Label").position = Vector2(0,blueprints[i["blueprint"]]["width"])
				shipnodes.append(ship)
				ships.append(ship)
				ship.shipid = cur_id
				cur_id = cur_id + 1
				add_child(ship)
		
		if location["type"] == "Moon":
			$battlefield/mass.show()
			$battlefield/mass_label.show()
			mass = location["mass"] * 10
			$battlefield/mass_label.text = str(mass)
			
	var spawnorder = 1
	if gamestate.spaces[spaceid]["type"] == "Planet":
		for i in gamestate.spaces[spaceid]["army"]["mmechs"]:
				var newmech = mech_asset.instance()
				newmech.type = "mmech"
				newmech.faction = gamestate.spaces[spaceid]["faction"]
				newmech.spawnorder = spawnorder
				newmech.mechid = mechs.size()
				mechs.append(newmech)
				get_node("battlefield").add_child(newmech) 
				spawnorder += 1
		for i in gamestate.spaces[spaceid]["army"]["amechs"]:
				var newmech = mech_asset.instance()
				newmech.type = "amech"
				newmech.faction = gamestate.spaces[spaceid]["faction"]
				newmech.spawnorder = spawnorder
				newmech.mechid = mechs.size()
				mechs.append(newmech)
				get_node("battlefield").add_child(newmech) 
				
				spawnorder += 1
		for i in gamestate.spaces[spaceid]["army"]["mechs"]:
				var newmech = mech_asset.instance()
				newmech.type = "mech"
				newmech.faction = gamestate.spaces[spaceid]["faction"]
				newmech.spawnorder = spawnorder
				newmech.mechid = mechs.size()
				mechs.append(newmech)
				get_node("battlefield").add_child(newmech) 
				spawnorder += 1
				
		
	
	
		gamestate.spaces[spaceid]["army"]["mechs"] = 0
		gamestate.spaces[spaceid]["army"]["mmechs"] = 0
		gamestate.spaces[spaceid]["army"]["amechs"] = 0
		
	#Set up battle camera	
		
	get_node("../Camera2D")._current_zoom_level = 3
	get_node("../Camera2D")._update_zoom(0.05, Vector2(960, 1080))
	get_node("CanvasLayer/scene/Node2D/map_click").map_ratio = 500
	
	for i in shipnodes:
		if i.faction == gamestate.player_info.name:
			get_node("../Camera2D").set_offset(i.position)
			return
		
		
		
		
sync func destroy_comp(shipid, destroy):
	var child = shipnodes[shipid].componentnodes[destroy] #Gets the node for the component
	child.destroy()
	
	
	



func _on_Unload_pressed():
	if selectedships.size() > 0:
		var selectedshipids = []
		for i in selectedships:
			rpc("queue_unload",battletimer + lag_delay, i.shipid)
		selectedships = []
		


func _on_Load_pressed():
	if selectedships.size() > 0:
		var selectedshipids = []
		for i in selectedships:
			rpc("queue_load",battletimer + lag_delay, i.shipid)
		selectedships = []


func _on_End_pressed():
	if (get_tree().is_network_server()):
		rpc("end_battle")
		
sync func end_battle():
	queuedorders = []
	queuedorders2 = []
	$background/background.hide()
	battle_paused = true
	get_node("../Camera2D")._current_zoom_level = 1
	get_node("../Camera2D").set_offset(Vector2(0, 0))
	get_node("../Camera2D")._update_zoom(0.05, Vector2(960, 540))
	$CanvasLayer/Paused.hide()
	
	Main.sequence = "orders"
	Main.clickstate = "open"
	selectedships = []
	
	for l in $CanvasLayer/scene/map.get_children():
		l.queue_free()
	
	for l in shipnodes:
		if l.towee[0] != l:
			l.ship["towed"] = [l.towee[0].check_mobility(), l.towee[0].ship["return"]]
			
		l.queue_free()
	get_tree().call_group("shots", "queue_free")
	hide()
	get_node("CanvasLayer/scene").hide()
	Main.get_node("CanvasLayer/UI").show()
	location["nodeid"].get_node("selectable").modulate = Color(1,1,1,1)
	location["nodeid"].get_node("selectable").hide()
	
	for l in gamestate.factions.values():
		for i in range(l["ships"].size() - 1, -1, -1):
			if l["ships"][i]["launched"] == "destroyed":
				if Main.fleets.has(l["ships"][i]["faction"] + l["ships"][i]["name"]):
					Main.fleets[l["ships"][i]["faction"] + l["ships"][i]["name"]].queue_free()	
					Main.fleets.erase(l["ships"][i]["faction"] + l["ships"][i]["name"])
				l["ships"].remove(i)
			
	
	if location["type"] == "Planet":
		for i in mechs :
			if i.type == "mech" and i.status == "alive":
				location["army"]["mechs"] = location["army"]["mechs"] + 1
			elif i.type == "amech" and i.status == "alive":
				location["army"]["amechs"] = location["army"]["amechs"] + 1
			elif i.type == "mmech" and i.status == "alive":
				location["army"]["mmechs"] = location["army"]["mmechs"] + 1
	
	
	
	for i in mechs:
		if location["type"] == "Planet" and i.status == "alive":
			location["faction"] = i.faction
		i.status = "dead"
		i.queue_free()
	mechs = []
	location["nodeid"].update_planet_info()
	Main.broadcast_self()

func _on_Enter_pressed():
	if selectedships.size() > 0:
		for i in selectedships:
			rpc("queue_combat",battletimer + lag_delay, i.shipid)
	
				
sync func give_command(shipids, command):
	var shipstocommand = []
	for i in shipids:
		shipstocommand.append(shipnodes[i])
	for i in shipstocommand:
		if i.hulls > 0 and i.mission != "exit":
			i.mission = command				

func _on_Retreat_pressed():
	if selectedships.size() > 0:
		for i in selectedships:
			rpc("queue_retreat",battletimer + lag_delay, i.shipid)
		selectedships = []
		
func _on_Tow_pressed():
	if selectedships.size() > 0:
		for i in selectedships:
			i.towing = true
			

func _on_Stand_pressed():
	if selectedships.size() > 0:
		for i in selectedships:
			rpc("queue_stand",battletimer + lag_delay, i.shipid)
		selectedships = []
				
sync func loadmass(shipid, componentid):
	var shipnode = shipnodes[shipid]
	var componentnode = shipnode.componentnodes[componentid]
	componentnode.data[2] = componentnode.data[2] + 1
	mass = mass -1
	get_node("battlefield/mass_label").text = str(mass)
	if componentnode.data[3] == "ready":
		componentnode.data[3] = "mass"
		componentnode.get_node("Label").show()
		componentnode.get_node("Sprite").texture = load("res://Ships/Box.png")
	componentnode.get_node("Label").text = str(componentnode.data[2])
	

	
sync func destroy_mech(mechid):
	mechs[mechid].status = "dead"
	mechs[mechid].get_node("Sprite").modulate = Color(0.3,0.3,0.3,1)
	mechs[mechid].get_node("flash").set_emitting(true)
	mechs[mechid].get_node("flash").show()
	var count = 0
	for i in mechs:
		if i.status == "alive":
			count = count +1
	
		
	
	
sync func assign_target(firingship, firingcomponent, target):
	shipnodes[firingship].componentnodes[firingcomponent].target = shipnodes[target]
	if shipnodes[firingship].target == shipnodes[firingship]:
		shipnodes[firingship].target = shipnodes[target]
#	if shipnodes[firingship].componentnodes[firingcomponent].data[0] == "glaser" or shipnodes[firingship].componentnodes[firingcomponent].data[0] == "rlaser":
#		for i in shipnodes[firingship].componentnodes:
#			if i.data[0] == "glaser" or i.data[0] == "rlaser":
#				i.target = shipnodes[target]
				
sync func fire_weapon(firingship, component, weapon):
	shipnodes[firingship].componentnodes[component].fire_weapon(weapon)
				
sync func assign_target_ground(firingship, firingcomponent, target):
	shipnodes[firingship].componentnodes[firingcomponent].target = mechs[target]
	
sync func assign_target_mech(firingmech, target):
	mechs[firingmech].target = mechs[target]
	
	
sync func assign_target_mmech(firingmech, target):
	mechs[firingmech].target = shipnodes[target]
	
	
sync func assign_tow(towee, tower):
	rpc("queue_tow", battletimer + lag_delay, tower, towee)
	shipnodes[towee].towing = false
	
	
	
func _input(event):
	if event.is_action_pressed("pause"):
		if battle_paused == false:
			rpc("pause_toggle_queue", str(gamestate.player_info.name), (battletimer + lag_delay) ,"pause")
		elif gamestate.factions[gamestate.player_info.name]["battle_paused"] == false:
			rpc("pause_toggle_queue", str(gamestate.player_info.name), (continuoustimer + lag_delay) ,"pause2")
		else:
			rpc("pause_toggle_queue", str(gamestate.player_info.name), (continuoustimer + lag_delay), "unpause")
	
	elif event.is_action_pressed("cam_drag"):
		var index = 0
		
		for i in selectedships:
			if i.towing == true:
				pass
			elif i == selectedships[0]:
				#i.get_node("navigation").travel_target = get_global_mouse_position()
				i.mission = "combat_travel"
				rpc("queue_combat_travel", battletimer + lag_delay, i.shipid, get_global_mouse_position())
				
			else:
				index = index + 1
				#i.get_node("navigation").escort(selectedships[0], index)
				#i.mission = "combat_escort"
				rpc("queue_combat_escort", battletimer + lag_delay, i.shipid, selectedships[0].shipid, index)
				
				
		
		
		
		
		
func pause_toggle(player):
	#print(battletimer)
	gamestate.factions[player]["battle_paused"] = !gamestate.factions[player]["battle_paused"]
	battle_paused = false
	$CanvasLayer/Paused.update()
	for j in network.players.values():
		if factions.has(j["name"]):
			if gamestate.factions[j["name"]]["battle_paused"] == true:
				battle_paused = true
			

	
sync func pause_toggle_queue(player, timer, state):
	if state == "pause":
		queuedorders.append([timer, "pause_game" , player])
		#print(timer - battletimer)
	elif state == "pause2":
		queuedorders2.append([timer, "pause_game" , player])
	else:
		queuedorders2.append([timer, "unpause_game" , player])
		#print(timer - continuoustimer)
	
sync func queue_destroy_comp(timer, shipid, componentid):
	queuedorders.append([timer, "destroy_comp", shipid, componentid])
	
sync func queue_burn(timer, shipid, accuracy):
	queuedorders.append([timer, "burn", shipid, accuracy])
	
sync func queue_combat_travel(timer, ship, destination):
	queuedorders.append([timer, "combat_travel", ship, destination])
	
sync func queue_combat_escort(timer, ship, target, index):
	queuedorders.append([timer, "combat_escort", ship, target, index])
	
sync func queue_load(timer, ship):
	queuedorders.append([timer, "load", ship])
	
sync func queue_unload(timer, ship):
	queuedorders.append([timer, "unload", ship])
	
sync func queue_retreat(timer, ship):
	queuedorders.append([timer, "retreat", ship])

sync func queue_tow(timer, ship, target):
	queuedorders.append([timer, "tow", ship, target])
	
sync func queue_combat(timer, ship):
	queuedorders.append([timer, "combat", ship])
	
sync func queue_stand(timer, ship):
	queuedorders.append([timer, "stand", ship])




func _on_Orders_pressed():
	for i in shipnodes:
		#if i.faction == gamestate.player_info.name:
		var boolean = i.get_node("Label").missionvisible
		i.get_node("Label").missionvisible =  !boolean
		
		
		


func _on_Assume_Command_pressed():
	if selectedships.size() > 0:
		for i in shipnodes:
			if i.control == "Player":
				i.control = "AI"
				rpc("other_player_control",selectedships[0].shipid, false)
			if i.control2 == "observed":
				i.control2 = "AI"
		if Input.is_key_pressed(KEY_Z):
			selectedships[0].control2 = "observed"
		else:
			rpc("other_player_control",selectedships[0].shipid, true)
			selectedships[0].control = "Player"
		
remote func other_player_control(shipid, value):
	if value == true:
		shipnodes[shipid].control = "Other Player"
	else:
		shipnodes[shipid].control = "AI"
	
	
		
sync func set_target_power_ratio(shipid, value):
	shipnodes[shipid].target_power_ratio = value
	
sync func accelerate(shipid):
	var ship = shipnodes[shipid]
	if ship.speed < ship.max_speed:
		ship.speed = ship.speed + ship.boost_rate
	
sync func turn_left(shipid):
	var ship = shipnodes[shipid]
	ship.rotation = ship.rotation - ship.turn_rate 
	ship.get_node("navigation").ai_turn = "left"
	ship.get_node("navigation").turn_history.remove(0)
	ship.get_node("navigation").turn_history.append(1)
	
sync func turn_right(shipid):
	var ship = shipnodes[shipid]
	ship.rotation = ship.rotation + ship.turn_rate  
	ship.get_node("navigation").ai_turn = "right"
	ship.get_node("navigation").turn_history.remove(0)
	ship.get_node("navigation").turn_history.append(-1)
	
sync func turn_center(shipid):
	var ship = shipnodes[shipid]
	ship.get_node("navigation").ai_turn = "center"
	ship.get_node("navigation").turn_history.remove(0)
	ship.get_node("navigation").turn_history.append(0)
	
sync func deccelerate(shipid):
	var ship = shipnodes[shipid]
	if ship.speed > 0:
		ship.speed = ship.speed - ship.boost_rate
	if ship.speed < 0:
		ship.speed = 0
		
remote func update_ship(shipid, pos, speed, rot, timestamp):
	var ship = shipnodes[shipid]
	ship.speed = speed
	ship.position = pos 
	ship.rotation = rot







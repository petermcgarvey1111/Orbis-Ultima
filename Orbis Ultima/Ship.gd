extends KinematicBody2D


# Constants
var core = Vector2(0,0)
#onready var gamestate.player_info.name = gamestate.player_info.name
#onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]

# This Ship
onready var battle = get_parent()
onready var designdata = get_node("../../designdata")
onready var component_asset = preload("res://component.tscn")
var currentscale = 1
var ship = {}
var target = self
var control = "AI"
var control2 = "AI"
var radius = 500

onready var unloadradius = battle.unloadradius
onready var turretradius = battle.turretradius
onready var missileradius = battle.missileradius
onready var combatradius = battle.combatradius
onready var pursuitradius = battle.pursuitradius
onready var deepradius = battle.deepradius
onready var exitradius = battle.exitradius

var startangle = PI/2
var components = []
var hulls = 10
var shipid = 100
var componentnodes = []
var mission = "none"
var faction = "none"
var numunloaded = 1
var type = "ship"
var status = "alive"
var mobilitystatus = 0
var threatstatus = false
var configuration = []
var towtarget = self
var towing = false
var orbitdirection = 1
var towee = [self, self]
var unloaded = 0
var velocity = Vector2(0,0)
var acceleration = 0
var direction = Vector2(0,0)
var turn_rate = 0
var boost_rate = 0
var turn_rate_static = 0
var boost_rate_static = 0
var speed = 500
var weight = 0
var power_ratio = 0.5
var max_speed = 1000
var target_power_ratio = 0.5
onready var delta2 = battle.delta2
var detected_by = []
var effective_range = 0




func _ready():
	var mapobj = load("res://map_icon.tscn").instance()
	mapobj.ship = self
	mapobj.faction = faction
	battle.get_node("CanvasLayer/scene/map").add_child(mapobj)
	
	
	var blueprint = designdata.blueprints[ship["configuration"]["blueprint"]]
	configuration = ship["configuration"]
	
	components = configuration["components"]
	
	
	
	get_node("Sprite").texture = load(blueprint["texture"])
	hulls = 0
	
	
	for i in components:
		weight = weight + 1
		if i[0] == "hull":
			hulls = hulls + 1
	
	
	for i in blueprint["components"]:
			var component = component_asset.instance()
			component.position = Vector2(i[1], i[2])
			component.data = i
			componentnodes.append(component)
	
	check_mobility()
	check_threat()
	
	
	if mobilitystatus == 0:
		radius = turretradius
		speed = 0
	elif ship["stance"] == "passive" and gamestate.spaces[ship["location"]]["type"] != "Moon":
		radius = deepradius
	elif ship["stance"] == "active":
		radius = combatradius
	else:
		radius = combatradius
		
	
		
	var ind = 0		
	for i in components:
			componentnodes[ind].rotation = i[4] * PI/180
			if i[0] == "hull":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/hull.png")
			elif i[0] == "engine":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/engine.png")
			elif i[0] == "booster":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/booster.png")
				componentnodes[ind].position = componentnodes[ind].position + Vector2(-6,0)
				componentnodes[ind].set_z_index(-1)
			elif i[0] == "laser":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/laser.png")
			elif i[0] == "rlaser":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/rlaser.png")
			elif i[0] == "glaser":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/glaser.png")
			elif i[0] == "storage":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/storage.png")
			elif i[0] == "orbital1":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/orbital2.png")
			elif i[0] == "orbital2":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/orbital1.png")
			elif i[0] == "orbital3":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/orbital3.png")
			
			elif i[0] == "bombs":
				if i[2] == 0:
					componentnodes[ind].get_node("Sprite").texture = load("res://Components/0bombs.png")
				else:
					componentnodes[ind].get_node("Sprite").texture = load("res://Components/bombs.png")
			elif i[0] == "missile":
				if i[2] == 0:
					componentnodes[ind].get_node("Sprite").texture = load("res://Components/0missile.png")
				else:
					componentnodes[ind].get_node("Sprite").texture = load("res://Components/missile.png")
				
			elif i[0] == "hook":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/hook.png")
				componentnodes[ind].position = componentnodes[ind].position + Vector2(-6,0)
				i[3] = "ready"
				
				
			
			if i[3] == "mech":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/mech.png")
				componentnodes[ind].get_node("Sprite").modulate = gamestate.factions[faction]["char_color"]
			elif i[3] == "2mechs":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/2mechs.png")
				componentnodes[ind].get_node("Sprite").modulate = gamestate.factions[faction]["char_color"]
			elif i[3] == "amech":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/amech.png")
				componentnodes[ind].get_node("Sprite").modulate = gamestate.factions[faction]["char_color"]
			elif i[3] == "mmech":
				componentnodes[ind].get_node("Sprite").texture = load("res://Components/mmech.png")
				componentnodes[ind].get_node("Sprite").modulate = gamestate.factions[faction]["char_color"]
			elif i[3] == "mass":
				componentnodes[ind].get_node("Sprite").texture = load("res://Ships/Box.png")
				componentnodes[ind].get_node("Label").show()
				componentnodes[ind].get_node("Label").text = str(i[2])
				
			componentnodes[ind].data = i
			ind = ind + 1
	
			
	var index = 0	
	var todestroy = []	
	for i in componentnodes:	
		i.componentid = index
		add_child(i)	
		if i.data[3] == "destroyed":
			todestroy.append(i)
		index = index + 1
		
	index = 0
	for i in todestroy:
		#componentnodes[index].destroy()
		i.destroy()
		index = index + 1
				
	
func check_mobility():
	mobilitystatus = 0
	turn_rate_static = 0
	boost_rate_static = 0
	for i in components:
		if i[0] == "engine" and i[3] == "ready":
			mobilitystatus = mobilitystatus + 1		
			turn_rate_static = turn_rate_static + PI/180 * 0.15
			boost_rate_static = boost_rate_static + 0.5
		elif i[0] == "booster" and i[3] == "ready":
			mobilitystatus = mobilitystatus + 1		
			turn_rate_static = turn_rate_static + PI/180 * 0.15
			boost_rate_static = boost_rate_static + 0.5
		
	
	
	var effective_weight = weight
	if towtarget != self and towtarget.towee[0] == self:
		effective_weight = weight + towtarget.weight
		
	turn_rate_static = turn_rate_static / pow(effective_weight,0.8) * 10
	boost_rate_static = boost_rate_static / pow(effective_weight,0.8) * 10 
	if mobilitystatus == 0:
		mission = "nonmobile"
	return mobilitystatus
			
func check_threat():
	var effective_range_array = []
	threatstatus = false
	for i in components:
		if i[0] == "laser" and i[3] == "ready":
			threatstatus = true
			effective_range_array.append(designdata.firetable["laser"][5])
		elif i[0] == "glaser" and i[3] == "ready":
			threatstatus = true		
			effective_range_array.append(designdata.firetable["glaser"][5])
		elif i[0] == "rlaser" and i[3] == "ready":
			effective_range_array.append(designdata.firetable["rlaser"][5])
			threatstatus = true		
	
	if threatstatus == false:
		remove_from_combat(self)
	else:
		effective_range_array.sort()
		effective_range = effective_range_array[int(effective_range_array.size()/2)]

func turn_left():
	rotation = rotation - turn_rate 
	
	
func turn_right():
	rotation = rotation + turn_rate  
	
func accelerate():
	if speed < max_speed:
		speed = speed + boost_rate
	
func deccelerate():
	if speed > 0:
		speed = speed - boost_rate
	if speed < 0:
		speed = 0
	
func _physics_process(delta):
	
	delta = delta2
	if battle.battle_paused == false:
		
		if towee[0] == self:
			velocity = Vector2(cos(rotation), sin(rotation)) * speed
			
			if target_power_ratio > power_ratio:
				power_ratio = power_ratio + 0.03 * delta
			elif target_power_ratio < power_ratio:
				power_ratio = power_ratio - 0.03 * delta
			
			max_speed = 1000 * (power_ratio) * 2
			
			boost_rate = boost_rate_static * (power_ratio) * 2
			turn_rate = turn_rate_static * (1 - power_ratio) * 2
			
			position = position + velocity * delta
			
		else:
			position = towee[1].get_global_position()	
			towee[0].check_mobility()
				
					
			
			
			
		if control == "Player" or control2 == "observed":
			get_node("../../Camera2D").set_offset(get_node("../../Camera2D").get_offset() + velocity * delta)
	
		if position.distance_to(towtarget.position) < 50 and towtarget != self:
			connect_hook(towtarget)
			
				
	
	
	if hulls < 1:
		$Sprite.modulate = Color(0.8, 0.2, 0.2, 1)
		if battle.battle_paused == false:
			if currentscale < 0.02:
				hide()
			else:
				currentscale = currentscale * (1 - delta / 15)
				scale = Vector2(currentscale, currentscale)
	elif battle.selectedships.has(self):
		$Sprite.modulate = Color(1.2, 1.2, 1.2, 1)
	else:
		var blank = Color(1,1,1,0.75)
		var blended = Color(gamestate.factions[faction]["char_color"]).blend(blank)
		$Sprite.modulate = Color(blended)
		

func _process(delta):
	if detected_by.has(gamestate.player_info.name):
		show()
	elif battle.factions.has(gamestate.player_info.name):
		hide()
	else:
		show()

	
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight


func check_hulls():
	if hulls < 1:
		
		for i in componentnodes:
			if i.data[3] != "destroyed":
				i.destroy()
		status = "dead"		
		ship["launched"] = "destroyed"
		get_node("Label").hide()
		remove_from_combat(self)
		set_collision_layer_bit( 0, false )

func remove_from_combat(ship):
	for i in get_parent().shipnodes:
			if i.target == self:
				i.target = i
				
				
func connect_hook(towtarget):
	for i in componentnodes:
		if i.data[0] == "hook" and i.data[3] == "ready":
			i.data[3] = "hooked"
			towtarget.mission = "towed"
			towtarget.towee = [self, i]
			mission = "exit"
			return
			
			
func fire_missile(target):
	for i in componentnodes:
		if i.data[0] == "missile" and i.data[3] == "ready" and i.data[2] == 1:
			battle.assign_target( shipid, i.componentid, target.shipid)
			battle.fire_weapon( shipid, i.componentid, "missile")
			return
		
sync func burn(accuracy):
	
	for destroy in componentnodes.size():
		var rng = battle.rg.randf() * 100
		if rng < accuracy and hulls > 0:
			battle.destroy_comp( shipid, destroy)

			
func get_capacity():
	var capacity = 0
	for i in componentnodes:
		if i.data[3] == "ready" and i.data[0] == "storage": 
			capacity = capacity + 10
		elif i.data[3] == "mass":
			capacity = capacity + (10 - i.data[2])
	return capacity
		

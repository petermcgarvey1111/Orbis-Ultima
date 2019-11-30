extends Node

var blueprints = {}
var component_cost = {
	"hull":[2, 0.03, "res://Components/hull.png", "hull", "Hull: a ship is destroyed when it loses its last hull"], # Base cost, multiplier, texture, name
	"engine":[2, 0.25, "res://Components/engine.png", "engine", "Engine: Increases max flight distance and combat speed"],
	"storage":[2, 0, "res://Components/storage.png", "storage", "Storage: Can carry 10 resources, two mini mechs, or one large mech"],
	"laser":[2, 0.1, "res://Components/laser.png", "laser", "Yellow Laser: High rate of fire, good for fighting multiple small ships"],
	"glaser":[3, 0.1, "res://Components/glaser.png", "glaser", "Green Laser: High damage, low rate of fire"],
	"rlaser":[5, 0.1, "res://Components/rlaser.png", "rlaser", "Red Laser: Hits every component on target, good for fighting massive ships"],
	"bombs":[2, 0, "res://Components/bombs.png", "bombs", "Bombs: Can destroy mechs on a planet"],
	"hook":[2, 0, "res://Components/hook.png", "hook", "Hook: Tows stranded ships"],
	"booster":[1, 0.1, "res://Components/booster.png", "booster", "Booster: Like an engine but single use, will leave ships sranded"],
	"missile":[2.5, 0, "res://Components/missile.png", "missile", "Missile: One shot, heavy damage vs ships"],
	"orbital1":[1, 0, "res://Components/orbital2.png", "orbital1", "Orbital Tether: Close orbit"],
	"orbital2":[1, 0, "res://Components/orbital1.png", "orbital2", "Orbital Tether: Mid orbit"],
	"orbital3":[1, 0, "res://Components/orbital3.png", "orbital3", "Orbital Tether: Deep orbit"],
	"radar":[2, 0, "res://Components/radar.png", "radar", "Radar Scanner: Scans for enemy ships"],
	}

var firetable = {
	"laser":[0.06, 6, "random", "res://Shots/lasershot.png", 3000, 2000, 30],  #Reload , accuracy, weapon type, sprite, speedmult, range, maxangle
	"glaser":[3.0, 60, "heavy", "res://Shots/glasershot.png", 3000, 4000, 30],
	"missile":[1.0, 60, "missile", "res://Shots/missile.png", 2500, 2000, 0],
	"rlaser":[0.5, 0.1, "all", "res://Shots/none.png", 20000000, 3000, 20],
	"bombs":[0.5, 60, "bomb", "res://Shots/bomb.png", 100, 500, 10]
	}




var raven_config = {
	"cost":5,
	"name":"Raven",
	"components":[
	["hull",0,0,"ready",0],
	["hull",0,0,"ready",0],
	["engine",0,0,"ready",0],
	["engine",0,0,"ready",0],
	["engine",0,0,"ready",0],
	["hull",0,0,"ready",0],
	["hull",0,0,"ready",0],
	["hull",0,0,"ready",0],
	["laser",0,0,"ready",0],
	["laser",0,0,"ready",0],
	]}
	
	
var firefly_config = {
	"cost":4,
	"name":"Firefly",
	"components":[
	["hull",18,0,"ready",0],
	["hull",40,0,"ready",0],
	["engine",-22,0,"ready",0],
	["engine",-22,0,"ready",0],
	["engine",-70,0,"ready",0],
	["storage",-4,0,"ready",0],
	["storage",-26,0,"ready",0],
	]}
	
var cruiser_config = {
	"cost":6,
	"name":"Cruiser",
	"components":[
	["engine",-22,0,"ready",0],
	["engine",-70,0,"ready",0],
	["storage",-4,0,"ready",0],
	["laser",18,0,"ready",180],
	["hull",40,0,"ready",0],
	["hull",-3,0,"ready",0],
	["hull",-3,-0,"ready",0],
	["hull",-48,0,"ready",0],
	["hull",-3,0,"ready",0],
	["hull",-48,0,"ready",0],
	["glaser",-22,0,"ready",0],
	["glaser",-22,0,"ready",0],
	["glaser",-70,0,"ready",0],
	]}
	
var shuttle_config = {
	"cost":2,
	"name":"Shuttle",
	"components":[
	["hull",18,0,"ready",0],
	["hull",40,0,"ready",0],
	["engine",-22,0,"ready",0],
	["engine",-22,0,"ready",0],
	["storage",-4,0,"ready",0],
	["storage",-26,0,"ready",0],
	]}
	
var delusion_config = {
	"cost":2,
	"name":"Shuttle",
	"components":[
	["hull",18,0,"ready",0],
	["hull",40,0,"ready",0],
	["engine",-22,0,"ready",0],
	["engine",-22,0,"ready",0],
	["storage",-4,0,"ready",0],
	["storage",-26,0,"ready",0],
	]}
	
var T100_config = {
	"cost":2,
	"name":"T100",
	"components":[
	["hull",18,0,"ready",0],
	["storage",40,0,"ready",0],
	["engine",-22,0,"ready",0],
	]}
	
var F45_config = {
	"cost":2,
	"name":"F45",
	"components":[
	["hull",18,0,"ready",0],
	["hull",40,0,"ready",0],
	["engine",-22,0,"ready",0],
	["laser",-22,0,"ready",0],
	]}
	
	
	
var standard_ship = {
	"name":"Raven",
	"location":-1,
	"faction":"none",
	"destination":-1,
	"return":-1,
	"configuration": "Raven",
	"stance": "active",
	}

var standard_configs = []

func _ready():
	for blueprint in get_children():
		var blueprintname = blueprint.get_name()
		blueprints[blueprintname] = {}
		blueprints[blueprintname]["components"] = []
		blueprints[blueprintname]["texture"] = blueprint.texturename
		blueprints[blueprintname]["width"] = blueprint.sizex
		blueprints[blueprintname]["name"] = blueprintname
		var array = blueprint.get_children()
		for component in array:
			blueprints[blueprintname]["components"].append(["notype",component.position.x,component.position.y,"ready"])
	
	raven_config["blueprint"] = "Raven"
	firefly_config["blueprint"] = "Firefly"
	shuttle_config["blueprint"] = "Shuttle"
	cruiser_config["blueprint"] = "Cruiser"
	T100_config["blueprint"] = "T100"
	F45_config["blueprint"] = "F45"
	delusion_config["blueprint"] = "Delusion"
	
	standard_configs.append(raven_config)
	standard_configs.append(delusion_config)
	standard_configs.append(firefly_config)
	standard_configs.append(shuttle_config)
	standard_configs.append(cruiser_config)
	standard_configs.append(F45_config)
	standard_configs.append(T100_config)
	
	for i in standard_configs:
		i["cost"] = int(calculate_ship_cost(i)) 
		i["ai"] = calculate_ship_class(i)



func calculate_ship_cost(configuration):
	var base_cost = 0
	var multiplier = 1
	for i in configuration["components"]:
		base_cost = base_cost + component_cost[i[0]][0]
		multiplier = multiplier + component_cost[i[0]][1]
	var cost = int(base_cost * multiplier) + 2
	return cost
	
func calculate_ship_class(configuration):
	
	var i = configuration
	var combat = 0
	var assault = 0
	var maxrange = 0
	var weapons = 0
	var hulls = 0
	var storage = 0
	var bombs = 0
	var ship_class = "transport"
	var tow = 0
	var class_value = 0
	
	for u in i["components"]:
		if u[0] == "laser" or u[0] == "glaser" or u[0] == "rlaser" or u[0] == "missile":
			weapons = weapons + 1
		elif u[0] == "engine":
			maxrange = maxrange + 1
		elif u[0] == "hull":
			hulls = hulls + 1
		elif u[0] == "storage":
			storage = storage + 1
		elif u[0] == "bombs":
			bombs = bombs + 1
	
	assault = pow(bombs, 0.5)* pow(hulls, 0.5)
	combat = pow(weapons, 0.5) * pow(hulls, 0.5)
	
	class_value = storage
	
	if combat > class_value:
		ship_class = "escort"
		class_value = combat
	if assault > class_value:
		ship_class = "assault"
		class_value = assault
		
	
	
	var class_data = {
		"range": maxrange,
		"escort": combat,
		"transport": storage,
		"assault": assault,
		"tow": tow, 
		"ship_class": ship_class
		}
	
	return class_data



			
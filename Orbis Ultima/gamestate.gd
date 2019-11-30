extends Node
var rings = 4
var moons = 0
var planets = 0
var storms = 0
var startingplayers = 1
var startingmass = 78
var player_info = {
	name = "Player",                   # How this player will be shown within the GUI
	net_id = 1,                        # By default everyone receives "server ID"
	#actor_path = "res://player.tscn",  # The class used to represent the player in the gagamestate.player_info.name world
	char_color = Color(1, 1, 1)        # By default don't modulate the icon color
}

var spacessaved = []
var spaces = []
var realspaces = []
var Moons = []
var Planets = []
var factions = {}
var orderedfactions = []
var current_seed = 10


func generate_faction(name, color, ai):
	var newplayer = {}
	newplayer["name"] = name
	newplayer["char_color"] = color
	newplayer["mass"] = -999
	newplayer["ships"] = []
	newplayer["blueprints"] = {}
	newplayer["configurations"] = {}
	newplayer["home"] = 1000
	newplayer["battle_paused"] = !ai 
	newplayer["campaign_paused"] = !ai
	newplayer["ai"] = ai
	var string = str(name)
	factions[string] = (newplayer)
	orderedfactions.append(newplayer["name"])
	
sync func update_seed(num):
	current_seed = num
	
	
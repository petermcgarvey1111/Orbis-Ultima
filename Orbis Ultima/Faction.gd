extends TabContainer
var selectedplanet = -1
##onready var gamestate.player_info.name = gamestate.player_info.name
##onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]
onready var Main = get_node("../../..")
# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	pass # Replace with function body.

# Called every fragamestate.player_info.name. 'delta' is the elapsed tigamestate.player_info.name since the previous fragamestate.player_info.name.
#func _process(delta):
#	pass


func _on_Ship_List_item_selected(x):
	pass
		

func _on_Ship_List_multi_selected(index2, selected):
	
	var index = get_node("Launch Menu/Ship List").get_selected_items()
	var array = get_node("Launch Menu/Ship List").array
		
	var ships = []
	for i in index:
		ships.append(array[i])
	var getrange = get_node("../../..").getleastrange(ships)
	
	var k =[]
	var destinations = get_node("../../..").get_destinations_in_dist(selectedplanet["nodeid"], getrange)
	k = destinations[0]
	for j in get_node("../../..").spaces:
		j.get_node("selectable").hide()
	for i in k:
		i.get_node("selectable").show()
			
	get_node("Launch Menu").selectedship = (array[index2])
	get_node("Launch Menu").show()
	get_node("Launch Menu")._on_item_selected(index2)
	return k
	
	
	
	
func check_in_range():
	
	var index = get_node("Launch Menu/Ship List").get_selected_items()
	var array = get_node("Launch Menu/Ship List").array
	
	var ships = []
	for i in index:
		ships.append(array[i])
	var getrange = get_node("../../..").getleastrange(ships)
	var destinations = get_node("../../..").get_destinations_in_dist(selectedplanet["nodeid"], getrange)
	var k = destinations[0]
	return k
	
func check_in_range_return():
	
	var index = get_node("Launch Menu/Ship List").get_selected_items()
	var array = get_node("Launch Menu/Ship List").array
	
	var ships = []
	for i in index:
		ships.append(array[i])
	var getrange = get_node("../../..").getleastrange(ships)
	var destinations = get_node("../../..").get_destinations_in_dist(selectedplanet["nodeid"], getrange)
	var k = destinations[0]
	return k

func _on_Build_pressed():
		if selectedplanet["faction"] == gamestate.player_info.name:
			get_node("Build Menu").buildoptions = []
			get_node("Build Menu/designs").clear()
			get_node("Build Menu").show()
			for i in gamestate.factions[gamestate.player_info.name]["configurations"].values():
				get_node("Build Menu").buildoptions.append(i) 
				get_node("Build Menu/designs").add_item(i["name"])
			get_node("Build Menu/designs").select(0)
			get_node("Build Menu").configuration = get_node("Build Menu").buildoptions[0]
			get_node("Build Menu")._on_Designs_item_selected(0)
			
			
func initialize_planet(planetnode):
	get_node("Launch Menu/Ship List").array = [] # Clear ship list
	get_node("Launch Menu/Ship List").clear()
	get_node("Launch Menu").show()
	selectedplanet = gamestate.spaces[planetnode.spaceid] # Register dictionary of the planet that was clicked
	#Main.selectedplanet1 = get_node("..").spaceid
	
	get_node("Launch Menu/Name").text = selectedplanet["name"]
	
	for l in gamestate.factions[gamestate.player_info.name]["ships"]:
		
		if l["location"] == planetnode.spaceid and l["launched"] == "home":
			get_node("Launch Menu/Ship List").array.append(l)
			get_node("Launch Menu/Ship List").add_item(l["name"])
	for j in Main.spaces:
			j.get_node("selectable").hide()
	if get_node("Launch Menu/Ship List").array.size() > 0:
		var maxrange = get_range(get_node("Launch Menu/Ship List").array[0])
		var destinations = Main.get_destinations_in_dist(planetnode, maxrange)
		
		for i in destinations[0]:
			i.get_node("selectable").show()
		get_node("Launch Menu/Ship List").select(0)
		_on_Ship_List_multi_selected(0, true)
	
	get_node("Launch Menu").update_ship_display()
	set_current_tab(0)	

		

func get_range(ship):
	var engines = 0
	for l in ship["configuration"]["components"]:
		if l[0] == "engine" and l[3] == "ready":
			engines = engines + 1
	return engines
		
func _process(delta):
	var isvisible = 0
	for i in get_children():
		if i.is_visible():
			isvisible = 1
	if isvisible == 1:
		show()
	else:
		pass
		hide()
		
		


func _on_Faction_tab_selected(tab):
	if tab == 1:
		_on_Build_pressed()
	elif tab == 3:
		get_node("Ship Design").initialize()
	elif tab == 0:
		get_node("Launch Menu").update_ship_display()
	elif tab == 2:
		$Recruitment.update_recruitment_panel()


func _on_bt_mech_pressed():
	pass # Replace with function body.

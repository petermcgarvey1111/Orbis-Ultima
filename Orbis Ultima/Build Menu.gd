extends Panel
var buildoptions = []
var cost = 0
var configuration = "none"
##onready var gamestate.player_info.name = gamestate.player_info["name"]
#onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]
onready var Main = get_node("../../../..")
var components = []
onready var component_asset = preload("res://design_comp.tscn")
 
# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	self.hide()

func _on_Designs_item_selected(index):
	components = []
	for i in $Design.get_children():
		if i.get_name() != "Sprite":
			i.queue_free()
			
	configuration = buildoptions[index]
	cost = configuration["cost"]
	$Cost.text = str(cost)
	$Name.text = configuration["name"]
	
	var blueprint = Main.get_node("designdata").blueprints[configuration["blueprint"]]
	
	get_node("Design/Sprite").texture = load(blueprint["texture"])
	
		# Load components from blueprint
	for i in blueprint["components"]:
		var component = component_asset.instance()
		
		component.rect_position = Vector2(i[1],i[2])  
		components.append(component)
		get_node("Design").add_child(component)
		
		
			
	var index2 = 0
	for l in configuration["components"]:
		components[index2].get_node("Sprite").texture = load("res://Components/" + l[0] + ".png")
		components[index2].component = l[0]
		components[index2].rect_rotation = l[4]
		index2 = index2 + 1
		
	
	
	
	

func _process(delta):
	if gamestate.factions[gamestate.player_info.name]["mass"] < cost:
		$Apply.modulate = Color(0.5,0.5,0.5,1)
	else:
		$Apply.modulate = Color(1,1,1,1)	
	


func _on_Apply_pressed():
	
			
	
	var stringlength =  $Name.text.length()
	var twodigits = $Name.text.right(stringlength-2)
	var onedigits = $Name.text.right(stringlength-1)
	var twodigitsl = $Name.text.left(stringlength-2)
	var onedigitsl = $Name.text.left(stringlength-1)
	var newname = $Name.text
	
	var hasname = 1
	
	
	while hasname == 1:
		stringlength =  $Name.text.length()
		twodigits = $Name.text.right(stringlength-2)
		onedigits = $Name.text.right(stringlength-1)
		twodigitsl = $Name.text.left(stringlength-2)
		onedigitsl = $Name.text.left(stringlength-1)
		
	
	
	
		if twodigits.is_valid_integer():
			for i in gamestate.factions[gamestate.player_info.name]["ships"]:
				if i["name"] == newname:
					hasname = 100
					newname = twodigitsl + str(int(twodigits) + 1)
			if hasname == 100:
				hasname = 1
				$Name.text = newname
			else:
				hasname = 0
				$Name.text = newname
				
		elif onedigits.is_valid_integer():
			for i in gamestate.factions[gamestate.player_info.name]["ships"]:
				if i["name"] == newname:
					hasname = 100
					newname = onedigitsl + str(int(onedigits) + 1)
			if hasname == 100:
				hasname = 1
				$Name.text = newname
			else:
				hasname = 0
				$Name.text = newname
			
		else:
			for i in gamestate.factions[gamestate.player_info.name]["ships"]:
				if i["name"] == newname:
					newname = newname + " 1"
					$Name.text = newname
					hasname = 100
					break
			if hasname == 100:
				hasname = 1
			else:
				hasname = 0
	
	
	
	if gamestate.factions[gamestate.player_info.name]["mass"] >= cost:
		gamestate.factions[gamestate.player_info.name]["mass"] = gamestate.factions[gamestate.player_info.name]["mass"] - cost
		var newship = Main.get_node("designdata").standard_ship.duplicate(true)
		newship["name"] = newname
		newship["location"] = get_node("..").selectedplanet["spaceid"]
		newship["launched"] = "home"
		newship["faction"] = gamestate.player_info.name
		newship["configuration"] = configuration.duplicate(true)
		newship["blueprint"] = newship["configuration"]["blueprint"]
		gamestate.factions[gamestate.player_info.name]["ships"].append(newship)
		get_node("../Launch Menu/Ship List").array.append(newship)
		get_node("../Launch Menu/Ship List").add_item(newship["name"])
		for i in newship["configuration"]["components"]:
			if i[0] == "bombs":
				i[2] = 2
			elif i[0] == "missile":
				i[2] = 1



		
	

func _on_Main_unselect():
	hide()

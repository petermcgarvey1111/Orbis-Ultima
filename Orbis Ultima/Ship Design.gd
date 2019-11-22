extends Panel

var cost = 0
var blueprint = "none"
var array = []
var types_array = []
var type_selected = 0
#onready var gamestate.player_info.name = gamestate.player_info["name"]
#onready var gamestate.factions[gamestate.player_info.name] = gamestate.factions[gamestate.player_info.name]
onready var Main = get_node("../../../..")
var components = []

onready var component_asset = preload("res://design_comp.tscn")

func _ready():
	#self.hide()
	pass

func initialize():
	$Design/Sprite.hide()
	components = []
	array = []
	types_array = []
	$blueprints.clear()
	$component_types.clear()
	$component_types.set_icon_scale(0.3)
	
	for i in $Design.get_children():
		if i.get_name() != "Sprite":
			i.queue_free()
			
	for i in Main.get_node("designdata").blueprints.values():
		$blueprints.add_item(i["name"])
		array.append(i)
		
	var index = 0	
	for i in Main.get_node("designdata").component_cost.values():
		$component_types.add_item("",load(i[2]))
		$component_types.set_item_tooltip(index, i[4])
		types_array.append(i)
		index = index + 1

func _on_Main_unselect():
	hide()

func update_blueprint(index):
	components = []
	for i in $Design.get_children():
		if i.get_name() != "Sprite":
			i.queue_free()
	
	
	blueprint = array[index]
	get_node("Design/Sprite").texture = load(blueprint["texture"])
	$Design/Sprite.show()
	$name.text = blueprint["name"]
	
	var ind = 0 
	for i in blueprint["components"]:
		var component = component_asset.instance()
		component.id = ind
		ind = ind + 1
		component.rect_position = Vector2(i[1],i[2])  
		get_node("Design").add_child(component)
		components.append("hull")
		
			
func update_configuration():
	var new_configuration = {}
	new_configuration["components"] = []
	var index = 1
	for i in components:
		var new_component = [i, 0, 0, "ready", $Design.get_children()[index].rect_rotation]
		new_configuration["components"].append(new_component)
		index = index + 1
	var newcost = Main.get_node("designdata").calculate_ship_cost(new_configuration)
	$Mass/Label.text = str(newcost)
	

func _on_blueprints_item_selected(index):
	update_blueprint(index)
	



func _on_component_types_item_selected(index):
	type_selected = index


func _on_create_configuration_pressed():
	
	var hashull = false
	for i in components:
		if i == "hull":
			hashull = true
	
	if gamestate.factions[gamestate.player_info.name]["configurations"].has($name.text) or hashull == false:
		pass
	else:
		var new_configuration = {}
		new_configuration["blueprint"] = blueprint["name"]
		new_configuration["name"] = $name.text
		new_configuration["components"] = []
		var index = 1
		for i in components:
			var new_component = [i, 0, 0, "ready" , $Design.get_children()[index].rect_rotation]
			new_configuration["components"].append(new_component)
			index = index + 1
		new_configuration["cost"] = Main.get_node("designdata").calculate_ship_cost(new_configuration)
		gamestate.factions[gamestate.player_info.name]["configurations"][new_configuration["name"]] = new_configuration
		initialize()
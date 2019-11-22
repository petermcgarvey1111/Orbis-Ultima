extends Node2D

#Variables that are necessary for Client:
var planetname = "Unnamed"
var faction = "none"
var radius = 0
var angle = 0
var arc = 0
var type = "empty"
var whichspace = 0
var spaceid = 999
var startangle = 0
#Variables that are constant:
var center = Vector2(1000,500)
var hidden = 0
var color = Color(1,1,1,1)


#Unnecessary variables for client:


# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	add_to_group("Spaces")
	add_to_group("Empty Spaces")
	position = center + radius * Vector2(cos(angle), sin(angle))
	get_node("C/Name").text = planetname
	get_node("selectable").hide()
	get_node("selected").hide()
	
	
func _process(delta):
	if get_node("..").mytimer > 0:
		var mytimer = get_node("..").mytimer
		angle = startangle + (mytimer * arc)/60
		if angle > 2*PI:
			angle = angle - 2*PI
		position = center + radius * Vector2(cos(angle), sin(angle))
	if type == "empty" and get_node("..").paused == 0:
		get_node("Sprite").modulate = Color(0.3,0.3,0.3,1)
	elif type == "empty" :
		get_node("Sprite").modulate = Color(0.6,0.6,0.6,1)

	if get_parent().clickstate == "battle":
		hide()
	else:
		show()
	

func _input(event):
	var just_pressed = event.is_pressed()
	if Input.is_key_pressed(KEY_Q) and just_pressed and type == "empty" and get_node("Sprite").is_visible():
		get_node("Sprite").hide()
	elif Input.is_key_pressed(KEY_Q) and just_pressed:
        get_node("Sprite").show()
		
sync func update_planet_info():
	if type == "Planet" :
		#print(gamestate.spaces[spaceid]["faction"])
		if gamestate.spaces[spaceid]["faction"] != "none":
			get_node("C/Army").add_color_override("font_color", gamestate.factions[gamestate.spaces[spaceid]["faction"]]["char_color"]) #Switch to faction color
			get_node("C/Name").add_color_override("font_color", gamestate.factions[gamestate.spaces[spaceid]["faction"]]["char_color"]) #Switch to faction color
			if spaceid == gamestate.factions[gamestate.spaces[spaceid]["faction"]]["home"]:
				get_node("Sprite").modulate = Color(gamestate.factions[gamestate.spaces[spaceid]["faction"]]["char_color"])
				gamestate.spaces[spaceid]["name"] = gamestate.factions[gamestate.spaces[spaceid]["faction"]]["name"]
		
		get_node("C/Name").show() #Show planet name label
		get_node("C/Name").text = gamestate.spaces[spaceid]["name"]
		var mechs = gamestate.spaces[spaceid]["army"]["mechs"]
		var amechs = gamestate.spaces[spaceid]["army"]["amechs"]
		var mmechs = gamestate.spaces[spaceid]["army"]["mmechs"]
		get_node("C/Army").text =( str(mechs) + "/" + str(amechs) + "/" + str(mmechs))
		if (mechs+amechs+mmechs) > 0:
			get_node("C/Army").show()
		else:
			get_node("C/Army").hide()
		
	
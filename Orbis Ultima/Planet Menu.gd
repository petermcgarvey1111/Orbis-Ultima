extends Panel


# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	self.hide()

func planet_menu(message):
	self.show()
	
	
func close():
	self.hide()
	get_node("Planet List").clear()
	get_node("Faction List").clear()
	
func apply():
	var planets = get_node("Planet List").get_selected_items() # Array for batch of planets to change.
	var faction = get_node("Faction List").get_selected_items() # Array that is one faction to change to.
	for i in planets:
		get_node("Planet List").array[i].faction = get_node("Faction List").array[1]["name"] # Change planet faction.
		var planet = get_node("Planet List").array[i] 
		var color = get_node("Faction List").array[1]["char_color"]
		planet.get_node("C/Name").add_color_override("font_color", color) # Change planet color.
		gamestate.spaces[planet.spaceid]["faction"] = get_node("Faction List").array[1]["name"]

		
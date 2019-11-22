extends Button

# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	var message = "Looking at planets"
	var menu = get_node("../../Planet Menu")
	self.connect("pressed", menu, "planet_menu", [message])
	menu = get_node("../../Planet Menu/Planet List")
	self.connect("pressed", menu, "planet_menu", [message])
	menu = get_node("../../Planet Menu/Faction List")
	self.connect("pressed",menu, "planet_menu", [message])
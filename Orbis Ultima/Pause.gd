extends Button

# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	var message = "The game is now paused"
	var main = get_node("/root/Main")
	self.connect("pressed", main, "pause_game", [message])
	
func _process(delta):
	if get_node("/root/Main").paused != 1:
		self.modulate = Color(0.5,0.5,0.5,1)
	else:
		self.modulate = Color(1,1,1,1)
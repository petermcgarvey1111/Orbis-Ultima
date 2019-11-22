extends Button

# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.

func _ready():
	self.connect("pressed", get_node(".."), "close")
	
extends Node2D
var ratio = Vector2(0.4,0.4)
var startpos = Vector2(500,500)
# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	self.scale = (ratio)
	position = startpos

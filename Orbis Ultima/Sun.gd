#extends Node2D
#var ratio = Vector2(0.4,0.4)
#var startpos = Vector2(0,0)
## Declare gamestate.player_info.namember variables here. Examples:
## var a = 2
## var b = "text"
#
## Called when the node enters the scene tree for the first tigamestate.player_info.name.
#func _ready():
#	self.scale = (ratio)
#	startpos = get_node("../..").center
#	self.position = startpos-


extends Sprite
var bright =0

func _process(delta):
	bright = randf() /15
	modulate = Color(1 + bright, 1 + bright, 1 + bright, 1)
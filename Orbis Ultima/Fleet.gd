extends Node2D

var shipname = ""
var color = Color(1,1,1,9)
var dictionary = {}
var center = Vector2(1000,500)
var fleetid = -1
var pos = Vector2(500,500)
var dest = Vector2(500,500)
var targetposition = Vector2(500,500)
var cycles = 0
var cyclesvar = 0
var targetvar = Vector2(0,0)

func _ready():
	
	cycles = get_node("..").cycles
	$Name.text = dictionary["name"]
	get_node("Name").add_color_override("font_color", color)
	$O.add_color_override("font_color", color)
	var xvar = randf() * 40 - 20
	var yvar = randf() * 40 - 20
	targetvar = Vector2(xvar, yvar)
	cyclesvar = randf() * 10 -5
	
	
	
	
func _route():
	pass
	

func _process(delta):
#	if dictionary["launched"] != "home":
#		show()
#	else:
#		hide()
	cycles = get_node("..").cycles + cyclesvar
	pos = gamestate.spaces[dictionary["location"]]["nodeid"].position
	if get_parent().sequence == "orders":
		dest = gamestate.spaces[dictionary["destination"]]["nodeid"]
	elif get_parent().sequence == "return":
		dest = gamestate.spaces[dictionary["return"]]["nodeid"]
	elif get_parent().sequence == "orbits": 
		dest = gamestate.spaces[dictionary["location"]]["nodeid"]
		
	dest = gamestate.spaces[dictionary["destination"]]["nodeid"]
	dest.angle = dest.startangle + dest.arc * (get_node("..").mytimer / 60)
	targetposition = center + dest.radius * Vector2(cos(dest.angle), sin(dest.angle))
	
	
	if dictionary["launched"] == "launched" and get_parent().sequence == "orbits":
		self.position = pos + targetvar
	elif dictionary["launched"] == "launched":
		self.position = pos + cycles * (targetposition - pos)/60 + targetvar
	elif dictionary["launched"] == "returning":
		self.position = targetposition + cycles * (pos - targetposition)/60 + targetvar
	elif dictionary["launched"] == "home":
		self.position = pos + targetvar
	
	if get_parent().clickstate == "battle":
		hide()
	elif dictionary["faction"] != gamestate.player_info.name:
		$Name.hide()
		show()
	else:
		show()
		$Name.show()
	
	
	
	
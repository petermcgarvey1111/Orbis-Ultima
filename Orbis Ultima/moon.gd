extends Node2D

# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0,0)
var gravity = Vector2(0,0)
var center = Vector2(0,0)
var distance = Vector2(0,0)
var ratio = Vector2(0.2,0.2)


# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	self.scale = (ratio)
	center = get_node("../..").center
	
	var radius = (randi() % 4 + 1) *100
	var angle = (randi() % 2) * PI
	var direction = Vector2(cos(angle), sin(angle)) 
	var velocitydirection = Vector2(cos(angle + PI/2 ), sin(angle + PI/2 )) 
	var speed = (randi() % 1 + 1) * radius / 5
	position = direction * radius + center
	velocity = velocitydirection * speed

# Called every fragamestate.player_info.name. 'delta' is the elapsed tigamestate.player_info.name since the previous fragamestate.player_info.name.
#func _process(delta):
#	pass
func _process(delta):
	position += velocity * delta
	center = get_node("../..").center
	gravity = self.global_position.direction_to (center)	
	distance = self.global_position.distance_squared_to (center)
	velocity = velocity + gravity * 100000 / distance	
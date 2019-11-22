extends Label

onready var camera = get_node("../../Camera2D")
onready var ship = get_parent()


func _process(delta):
	rotation = 0 - ship.rotation
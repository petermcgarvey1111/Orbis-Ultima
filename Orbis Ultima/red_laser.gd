extends Sprite

onready var faction = get_node("../..").faction
onready var battle = get_node("../../..")
onready var ship = get_node("../..")

func _ready():
	
	if get_parent().data[0] == "rlaser":
		get_node("../Sound").stream = load("res://Sounds/rlaser.wav")
		
	else:
		queue_free()
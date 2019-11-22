extends Label
onready var battle = get_node("../../../..")

func _process(delta):
	if get_node("../../../../..").clickstate == "battle":
		
#		for i in get_node("../../../..").shipnodes:
#			if i.control == "Player" or i.control2 == "observed":
		if battle.selectedships.size() > 0:
			show()
			var i = battle.selectedships[0]
			text = str(round(i.speed)) + " km/s"
			get_node("../Thrust/Thrust").value = i.speed
			get_node("../Thrust/Thrust/EngineBracket").position = Vector2(i.max_speed/10,21)
		else:
			hide()
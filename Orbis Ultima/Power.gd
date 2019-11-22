extends Label
onready var battle = get_node("../../../..")

func _process(delta):
	
	if get_node("../../../../..").clickstate == "battle":
#		for i in get_node("../../../..").shipnodes:
#			if i.control == "Player" or i.control2 == "observed":
#				text = str(round((1 - i.power_ratio ) * 100)/100) + "  rotational      " + str(round(i.power_ratio * 100)/100) + "  thrust"
#				get_node("../TurnGauge").modulate = Color(1.4 - i.power_ratio, 1.4 - i.power_ratio, 1.4 - i.power_ratio,1)
#				get_node("../Thrust").modulate = Color(0.5 + i.power_ratio, 0.5 + i.power_ratio, 0.5 + i.power_ratio, 1)
		
		if battle.selectedships.size() > 0:
			show()
			var i = battle.selectedships[0]
		
			
		
			text = str(round((1 - i.power_ratio ) * 100)/100) + "  rotational      " + str(round(i.power_ratio * 100)/100) + "  thrust"
			get_node("../TurnGauge").modulate = Color(1.4 - i.power_ratio, 1.4 - i.power_ratio, 1.4 - i.power_ratio,1)
			get_node("../Thrust").modulate = Color(0.5 + i.power_ratio, 0.5 + i.power_ratio, 0.5 + i.power_ratio, 1)
		else:
			hide()
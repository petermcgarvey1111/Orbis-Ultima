extends Label
var average = 0
onready var battle = get_node("../../../..")


func _process(delta):
	
	if get_node("../../../../..").clickstate == "battle":
#		for i in get_node("../../../..").shipnodes:
#			if i.control == "Player" or i.control2 == "observed":
		if battle.selectedships.size() > 0:
			get_parent().show()
			var i = battle.selectedships[0]
			text = str(round(i.turn_rate * 60 * 60)) + " deg/s"
			get_node("../TurnGauge/LeftGauge").rotation = (PI/2 - i.turn_rate * 60 + PI/180) 
			get_node("../TurnGauge/RightGauge").rotation = (-PI + i.turn_rate * 60 - PI/180)
			average = (average * 58 + i.get_node("navigation").turn_history2[59] * 2)/60.00 
			get_node("../TurnGauge/Dial").rotation = average * i.turn_rate * 180/PI * -1
		else:
			get_parent().hide()
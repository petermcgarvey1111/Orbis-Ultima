extends Node
onready var ship = get_parent()
onready var battle = get_node("../..")


func _process(delta):
	for i in battle.shipnodes:
		if ship.detected_by.has(i.faction):
			pass
		else:
			if ship.position.distance_to(i.position) < 6000:
				ship.detected_by.append(i.faction)
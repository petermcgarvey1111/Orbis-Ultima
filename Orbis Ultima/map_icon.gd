extends Node2D

var ship = 0
var faction = "none"


func _process(delta):
	position = ship.position / get_node("../../Node2D/map_click").map_ratio + Vector2(100,100)
	
	if ship.control == "Player":
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(gamestate.factions[ship.faction]["char_color"])
		
			
	if abs(ship.position.x) > get_node("../../Node2D/map_click").map_ratio * 95 or abs(ship.position.y) > get_node("../../Node2D/map_click").map_ratio * 95:
		if ship.mission == "exit" or ship.mission == "nonmobile":
			ship.status = "stranded"
		else:
			get_node("../../Node2D/map_click").map_ratio = get_node("../../Node2D/map_click").map_ratio + 1
			
	if ship.detected_by.has(gamestate.player_info.name) and ship.status == "alive":
		show()
	elif ship.battle.battle_fleets.has(gamestate.player_info.name):
		if ship.battle.battle_fleets[gamestate.player_info.name] == "alive":
			hide()
		elif ship.status == "alive":
			show()
	elif ship.status == "alive":
		show()


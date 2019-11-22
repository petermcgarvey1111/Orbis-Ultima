extends Panel
onready var board_asset = preload("res://PlayerData.tscn")
var numplayers = 0
var menus = 0
var started = 1

func _process(delta):
	if started == 1:
		numplayers = gamestate.factions.size()
		menus = get_child_count()
		
		
		if numplayers > menus:
			add_player_board()
		
		var menus2 = self.get_children()
		var x = 0
		if menus > 0:
			for i in gamestate.factions.values():
				menus2[x].get_node("playername").text = i["name"] +":"
				menus2[x].get_node("playername").modulate = Color(i["char_color"])
				menus2[x].get_node("ships").modulate = Color(i["char_color"])
				menus2[x].get_node("ships").text = "Ships: " + str(i["ships"].size())
				menus2[x].get_node("resources").text = str(i["mass"])
				var planets = 0
				for l in gamestate.spaces:
					if l["faction"] == i["name"]:
						planets = planets + 1
				menus2[x].get_node("planets").text = "Planets: " + str(planets)
				menus2[x].get_node("planets").modulate = Color(i["char_color"])
				x = x + 1
			
func add_player_board():
	var newplayerboard = board_asset.instance()
	add_child(newplayerboard)
	newplayerboard.rect_position = Vector2(0, menus * 44)
	menus = menus + 1
extends Button
onready var Main = get_node("../../../..")
var filepath = "ss"

func _on_Save_pressed():
	get_node("FileDialog").popup()

func _on_FileDialog_file_selected(path):
	var data = [Main.mytimer, Main.sequence]
	var save_array = [gamestate.factions, gamestate.spaces, data]
	var save_game = File.new()
	var savegame = File.new()
	save_game.open(path, File.WRITE)
	var jstr = JSON.print(save_array)
	save_game.store_line(jstr)
	save_game.close()



func _on_Load_pressed():
	get_node("FileDialog2").popup()

func _on_FileDialog2_file_selected(path):
	if (get_tree().is_network_server()):
		#First purge local nodes:
		for i in gamestate.spaces:
			i["nodeid"].queue_free()
		Main.emptyspaces = []
		Main.spaces = []	
		
		
		var array = []
		for i in Main.get_node("CanvasLayer/UI/PlayerList").get_children():
			array.append(i)
		
		for i in array:
			i.queue_free()
		
		Main.get_node("CanvasLayer/UI/PlayerList").menus = 0
		
		
		
		
		var save_game = File.new()
		save_game.open(path, File.READ)
		var save_text = save_game.get_as_text()
		save_game.close()
		var data_parse = JSON.parse(save_text)
		var save_array = data_parse.result
		
		gamestate.factions = save_array[0]
		Main.mytimer = save_array[2][0]
		Main.sequence = save_array[2][1]
		
	
		
			
		gamestate.spacessaved = save_array[1]
		gamestate.spaces = []
		Main.synchronize_all()
		for i in gamestate.spaces:
			i["nodeid"].update_planet_info()
		
		
		
		
		var index = 0
		for i in gamestate.spaces:
			if i["type"] == "Planet":
				i["army"] = gamestate.spacessaved[index]["army"]
			index = index +1 
		
		for i in range(gamestate.factions.size()):
			Main.get_node("CanvasLayer/UI/PlayerList").add_player_board()
		
		
		
		for i in Main.fleets.values():
			i.queue_free()
			
		Main.fleets = {}
		
			
		for i in gamestate.factions.values():
			for u in i["ships"]:
				if u["launched"] == "launched":
					var spawnfleet = Main.fleet_asset.instance()
					var dictionary = {"destination": u["destination"], "return": u["return"], "location": u["location"], "name":u["name"] , "launched":u["launched"], "faction":u["faction"]}
					spawnfleet.color = gamestate.factions[i["name"]]["char_color"]
					spawnfleet.dictionary = dictionary
					var fleetkey = u["faction"] + u["name"]
					Main.fleets[fleetkey] = spawnfleet
					Main.add_child(spawnfleet)
	





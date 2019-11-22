extends CanvasLayer

# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	
	network.connect("server_created", self, "_on_ready_to_play")
	network.connect("join_success", self, "_on_ready_to_play")
	network.connect("join_fail", self, "_on_join_fail")

func _on_ready_to_play():
	if (get_tree().is_network_server()):
		gamestate.rings = int(get_node("PanelHost/rings").text)
		gamestate.planets = int(get_node("PanelHost/planets").text)
		gamestate.moons = int(get_node("PanelHost/moons").text)
		gamestate.startingplayers = int(get_node("PanelHost/txtfactions").text)
		gamestate.startingmass = int(get_node("PanelHost/resources").text)
		gamestate.factions[gamestate.player_info.name]["mass"] = gamestate.startingmass
	get_tree().change_scene("res://Main.tscn")
		

func _on_btCreate_pressed():
	# Properly set the local player information
	set_player_info()
	gamestate.generate_me()
	
	# Gather values from the GUI and fill the network.server_info dictionary
	if (!$PanelHost/txtServerName.text.empty()):
		network.server_info.name = $PanelHost/txtServerName.text
	network.server_info.max_players = int($PanelHost/txtMaxPlayers.value)
	network.server_info.used_port = int($PanelHost/txtServerPort.text)
	
	# And create the server, using the function previously added into the code
	network.create_server()

func _on_btJoin_pressed():
	# Properly set the local player information
	set_player_info()
	gamestate.generate_me()
	var port = int($PanelJoin/txtJoinPort.text)
	var ip = $PanelJoin/txtJoinIP.text
	network.join_server(ip, port)

func _on_join_fail():
	print("Failed to join server")
	
func set_player_info():
	if (!$PanelPlayer/txtPlayerName.text.empty()):
		gamestate.player_info.name = $PanelPlayer/txtPlayerName.text
	gamestate.player_info.char_color = $PanelPlayer/btColor.color.to_html()
	



extends Node2D


func _process(delta):
	var children = get_children()
	for i in children:
		i.queue_free()
	var factions = get_node("../..").factions.duplicate()
	var index = 0
	for i in factions:
		if gamestate.factions[i]["battle_paused"] == true:
			var newlabel = Label.new()
			newlabel.modulate = gamestate.factions[i]["char_color"]
			newlabel.text = (i + " has paused the game")
			newlabel.rect_position = Vector2(0, index)
			index = index + 30
			add_child(newlabel)
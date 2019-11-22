extends Sprite

func _process(delta):
	if gamestate.rings < 1 or get_parent().get_parent().clickstate == "battle":
		hide()
	else:
		show()

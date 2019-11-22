extends Sprite

func _ready():
	modulate = Color(1,1,1,0.5)
	if gamestate.rings < 3:
		hide()
		
		
func _process(delta):
	if gamestate.rings < 3 or get_parent().get_parent().clickstate == "battle":
		hide()
	else:
		show()

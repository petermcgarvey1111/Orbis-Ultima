extends Sprite
var blank = Color(1,1,1,0.6)

func _on_btColor_color_changed(color):
	var blended = color.blend(blank)
	modulate = Color(blended)

extends ColorPickerButton

func _ready():
	#randomize()
	var var1 = randf() 
	var var2 = randf()
	var var3 = randf() 
	color = Color(var1,var2,var3,1)
	
	get_node("../Sprite")._on_btColor_color_changed(color)
	get_node("../Sprite2")._on_btColor_color_changed(color)
	get_node("../Sprite3")._on_btColor_color_changed(color)
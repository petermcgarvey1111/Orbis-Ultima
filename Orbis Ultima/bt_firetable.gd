extends Button
var showing = 0
var index = 0
onready var designdata = get_node("../../../../designdata")


func _on_bt_firetable_pressed():
	if showing == 0:
		$Panel.show()
		showing = 1
	else:
		$Panel.hide()
		showing = 0



func _ready():
	
	for i in designdata.component_cost.values():
		if designdata.firetable.has(i[3]):
			var sprite = Sprite.new()
			sprite.texture = load(i[2])
			sprite.position = Vector2(44, index * 30 + 40)
			sprite.scale = Vector2(0.2,0.2)
			$Panel.add_child(sprite)
			
			
			var accuracy = Label.new()
			accuracy.text = str(stepify(designdata.firetable[i[3]][1], 0.01))
			$Panel.add_child(accuracy)
			accuracy.rect_position = Vector2(229, index * 30 + 33)
			
			if i[3] != "bombs":
				var rof = Label.new()
				rof.text = str(stepify(1 / designdata.firetable[i[3]][0], 0.01))
				$Panel.add_child(rof)
				rof.rect_position = Vector2(129, index * 30 + 33)
			
			
			var type = Label.new()
			if designdata.firetable[i[3]][2] == "random":
				type.text = "Targets one random component."
			elif designdata.firetable[i[3]][2] == "heavy":
				type.text = "Targets two random components, preferring hulls."
			elif designdata.firetable[i[3]][2] == "all":
				type.text = "Targets every component on the ship."
			elif designdata.firetable[i[3]][2] == "bomb":
				type.text = "Targets mechs."
			$Panel.add_child(type)
			type.rect_position = Vector2(329, index * 30 + 33)
			
			
			index = index + 1
			
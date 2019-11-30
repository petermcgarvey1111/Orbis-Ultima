extends TextureButton

var component = "hull"
var id = 0
onready var ship_design = get_node("../..")
var position = Vector2(0,0)


func _ready():
	position = rect_position
	rect_rotation = 0

func _process(delta):
	$blast.hide()
	$booster.hide()
	$glaser.hide()
	$ylaser.hide()
	if component == "engine" and modulate == Color(1,1,1,1):
		$blast.show()
	elif component == "booster" and modulate == Color(1,1,1,1):
		$blast.show()
		$booster.show()	
		rect_position = position + Vector2(-5, 0)
	elif component == "laser" and modulate == Color(1,1,1,1):
		$ylaser.show()
	elif component == "glaser" and modulate == Color(1,1,1,1):
		$glaser.show()
	elif component == "hook":
		rect_position = position + Vector2(-5, 0)
	
		
	
		

func _on_design_comp_pressed():
	if ship_design.get_name() == "Ship Design":
		var component_index = ship_design.get_node("component_types").get_selected_items()[0]
		var component_set =   ship_design.types_array[ship_design.type_selected]
		if component == component_set[3] :
			if rect_position.y + 62.5 > 0:
				rect_rotation = rect_rotation + 30
			else: 
				rect_rotation = rect_rotation - 30
		else:
			rect_rotation = 0
			component = component_set[3]
			$Sprite.texture  = load(component_set[2])
			if component_set[3] == "booster":
				$Sprite.texture = load("res://Components/none.png")
			ship_design.components[id] = component
			ship_design.update_configuration()
	
	

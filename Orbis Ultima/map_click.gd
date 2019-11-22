extends Area2D

onready var camera = get_node("../../../../../Camera2D")
var map_ratio = 500.00
#func _input_event(viewport, event, shape_idx):
##	if event is InputEventMouseButton \
##	and event.button_index == BUTTON_LEFT \
##	and event.is_pressed():
#	print("minimap")
#	var mouse_pos = get_local_mouse_position()
#	camera.set_offset(mouse_pos * 500)
#
#
func _ready():
	set_process_input(true)
	
func _process(delta):
	if get_node("../../../../..").clickstate == "battle" and Input.is_mouse_button_pressed(BUTTON_LEFT):
		
		var mouse_pos = get_global_mouse_position()
		if abs( mouse_pos.x - (get_node("..").position.x)) < 100 and  abs( mouse_pos.y - (get_node("..").position.y)) < 100:
			var mouse_pos2 = get_local_mouse_position()
			camera.set_offset(mouse_pos2  * map_ratio - Vector2(960,540))
			camera.controls_active = false
			
			
		
			
	else:
		camera.controls_active = true
		
	get_node("../window").rect_size = Vector2(2000 / map_ratio * camera._current_zoom_level, 1120 / map_ratio * camera._current_zoom_level)
	get_node("../window").rect_position = (camera.get_offset() + Vector2(960,540) )/ map_ratio - get_node("../window").rect_size / 2

extends TextureRect

func _process(delta):
	rect_position =  - get_node("../../../../Camera2D").get_offset() /20
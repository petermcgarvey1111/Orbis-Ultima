extends Area2D

onready var Battle = get_node("../..")


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT \
			and event.is_pressed():
		   	self.on_click()
		elif event.button_index == BUTTON_RIGHT \
			and event.is_pressed():
		   	self.on_right_click()
	
func on_click():
	Battle.deselect_all()
	if get_parent().faction == gamestate.player_info.name:
		for i in Battle.selectedships:
			i.modulate = Color(1,1,1,1)
		if get_parent().hulls > 0:
			Battle.selectedships = [get_parent()]
			
		
func on_right_click():
	
	if Battle.selectedships.size() > 0:
		
		for i in Battle.selectedships:
			
			if i.towing == true and i.faction == get_parent().faction:
				Battle.assign_tow(  get_parent().shipid, i.shipid) 
				
				var toweeposition = (get_parent().position - Vector2(960, 540))
				var towerposition = (i.position - Vector2(960, 540))
				var angle = towerposition.angle_to(toweeposition)
				
			else:
				
				if i.faction != get_parent().faction:
					Battle.rpc("queue_assign_target", (Battle.battletimer + Battle.lag_delay), i, get_parent())
					
			
		
		
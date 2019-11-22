#extends TabContainer
#
#func _process(delta):
#	var isvisible = 0
#	for i in get_children():
#		if i.is_visible():
#			isvisible = 1
#	if isvisible == 1:
#		show()
#	else:
#		hide()
#
#
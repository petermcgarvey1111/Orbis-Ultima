extends ItemList
var array = []
func _ready():
	pass # Replace with function body.

func planet_menu(message):
	array = get_node("/root/network").players	
	for i in array:
		add_item(get_node("/root/network").players[i]["name"])
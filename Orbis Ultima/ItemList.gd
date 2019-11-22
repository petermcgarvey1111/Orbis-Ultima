extends ItemList
var array = ["dd"]
# Declare gamestate.player_info.namember variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first tigamestate.player_info.name.
func _ready():
	set_select_mode(1)
	pass

func planet_menu(message):
    array = get_tree().get_nodes_in_group("Planets")	
    for i in array:
	    add_item(i.planetname)
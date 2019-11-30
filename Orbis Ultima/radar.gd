extends Node2D

onready var faction = get_node("../..").faction
onready var battle = get_node("../../..")
onready var ship = get_node("../..")

func _ready():
	$scan.add_exception(get_node("../../Area2D"))
	if get_parent().data[0] != "radar":
		queue_free()
	

func _physics_process(delta):
	
	if battle.battle_paused == false:
		if get_parent().data[0] == "radar" and ship.hulls > 0:
			pass
		else:
			queue_free()
			
		if get_parent().data[3] == "ready":
			get_parent().rotation = get_parent().rotation + PI / 180	* 2		
			if $scan.is_colliding():
				var detected = $scan.get_collider().get_parent()
				if detected.detected_by.has(faction) == false:
					detected.detected_by.append(faction)
		
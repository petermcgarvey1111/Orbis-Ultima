extends Node
var timer_reload = 2
onready var battle = get_parent()


func _physics_process(delta):
	if battle.battle_paused == false:
		timer_reload -= delta
		if timer_reload < 0:
			timer_reload = 2
			for i in battle.factions:
				if gamestate.factions[i]["ai"] == true:
					
					
					#Check for battle is hopeless:
				
					var allied_strength = 0
					var enemy_strength = 0
					
					for j in battle.shipnodes:
						if j.faction == i:
							allied_strength += calculate_capability(j.configuration)
						elif j.detected_by.has(i):
							enemy_strength += calculate_capability(j.configuration)
					
					enemy_strength = enemy_strength / (battle.factions.size() - 0.8)		
					if enemy_strength > allied_strength * 1.8:
						print("enemies" + str(enemy_strength))
						print("friends" + str(allied_strength))
						for k in battle.shipnodes:
							if k.faction == i:
								k.mission = "exit"
				





func calculate_capability(configuration):
	
	var i = configuration
	var combat = 0
	var weapons = 0
	var hulls = 0
	
	for u in i["components"]:
		if u[0] == "laser" or u[0] == "glaser" or u[0] == "rlaser" or u[0] == "missile":
			if u[3] == "ready":
				weapons = weapons + 1

		elif u[0] == "hull" and u[3] == "ready":
			hulls = hulls + 1
	
	
	combat = pow(weapons, 0.5) * pow(hulls, 0.5)
	
	return combat
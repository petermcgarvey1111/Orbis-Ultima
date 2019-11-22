extends Node2D
onready var left = get_node("left_ray")
onready var right = get_node("right_ray")
onready var left2 = get_node("left_ray2")
onready var right2 = get_node("right_ray2")
onready var ship = get_parent()
onready var battle = get_node("../../")
onready var width = get_node("../../../designdata").blueprints[ship.ship["configuration"]["blueprint"]]["width"]
onready var delta2 = battle.delta2


var laser_range = 1000

var min_turn = 0
var target_projection = Vector2(0,0)
var me_him_angle = 0
var him_me_angle = 0
var think_time = 1
var travel_target = Vector2(-10000, -10000)
var search_started = false
var target_angle = 0
var ai_turn = "center"
var ai_boost = "steady"
var evade_time = 0
var turn_history = [0,0,0,0,0,0,0,0]
var turn_history2 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var timer2 = 0
var protocol = "none"

var escort_target = "none"
var escort_index = 0


func _ready():
	target_angle = ship.rotation
	left2.add_exception(get_node(".."))
	right2.add_exception(get_node(".."))
	left.add_exception(get_node(".."))
	right.add_exception(get_node(".."))
	
	left.position.y = -width/2
	right.position.y = +width/2
	var number = int(right.position.y)
	



func _physics_process(delta):
	delta = delta2
	#print(delta)
	timer2 = timer2 + delta
	#print(timer2)
	
	if battle.battle_paused == false and ship.towee[0] == ship:
		if ship.control == "AI" :
			#print(think_time)
			if think_time < 0.2:
				var dodge_response = avoid_obstacles()
			
				if dodge_response == "none":
					
				
					var anglediff = angle_difference(ship.rotation, target_angle)
					#print(anglediff)
					#print(target_angle)
					if anglediff > 0:
						ai_turn = "right"
						#print(str(timer2) + "right")
					elif anglediff < 0:
						ai_turn = "left"
						#print(str(timer2) + "left")
					else:
						#ship.rotation = ship.rotation + anglediff
						ai_turn = "center"
						#print(str(timer2) + "center")
				
				else:
					ai_turn = dodge_response
				
				turn_history.remove(0)
				turn_history2.remove(0)
			
			if abs(angle_difference(ship.rotation, target_angle)) < ship.turn_rate:
				ai_turn = "center"
				ship.rotation = target_angle
				turn_history.append(0)
				turn_history2.append(0)
			
			elif ai_turn == "left":
				ship.turn_left()
				turn_history.append(1)
				turn_history2.append(1)
			elif ai_turn == "right":
				turn_history.append(-1)
				turn_history2.append(-1)
				ship.turn_right()
			else:
				turn_history.append(0)
				turn_history2.append(0)
			
			if ship.max_speed < ship.speed:
				ship.deccelerate()
			elif ai_boost == "steady":
				pass
			elif ai_boost == "accelerate":
				ship.accelerate()
			elif ai_boost == "deccelerate":
				ship.deccelerate()
			
			if 1 == 1: #(get_tree().is_network_server()):
				think_time = think_time - delta
				if think_time < 0:
					think_time = 1.0/4.0
					
				
					if ship.mobilitystatus > 0:
						min_turn = PI/2 * ship.speed / ship.turn_rate / 60  + width 
						target_projection = ship.target.position + ship.target.velocity
						me_him_angle = abs(ship.get_angle_to(ship.target.position))
						him_me_angle = abs(ship.target.get_angle_to(ship.position))
					
						
					if battle.battle_paused == false and ship.hulls > 0:
						left.rotation = -PI/180
						right.rotation = PI/180
						left2.rotation = -PI/180
						right2.rotation = PI/180
						left.set_cast_to(Vector2(min_turn ,0))
						left2.set_cast_to(Vector2(min_turn ,0))
						right.set_cast_to(Vector2(min_turn ,0))
						right2.set_cast_to(Vector2(min_turn ,0))
						
						
						
						
						
						if ship.mission == "none":
							#ship.target = pick_new_target()
							ship.mission = "combat_travel"
							travel_target = Vector2(cos(ship.rotation), sin(ship.rotation)) * 30000 + ship.position
							
							
						
						elif ship.mission == "nonmobile":
							if abs(ship.position.x) > 50000 or abs(ship.position.y) > 50000:
								ship.status = "stranded"
								
						elif ship.mission == "stand":
							ship.target_power_ratio = 0.5
							ai_boost = "deccelerate"
							if ship.speed == 0:
								ship.mission = "combat_travel"
								travel_target = ship.position
								
						
						elif ship.mission == "tow":
							travel_target = ship.towtarget.position	
							left2.add_exception(ship.towtarget)
							right2.add_exception(ship.towtarget)
							left.add_exception(ship.towtarget)
							right.add_exception(ship.towtarget)
							travel_protocol()	
							
						
						
						elif ship.mission == "combat_travel":
							travel_protocol()
							
							var current_target_priority = 3
							for i in battle.shipnodes:
								if i.faction != ship.faction and i.status == "alive":
									if calculate_target_priority(i) <= current_target_priority:
										ship.target = i
										ship.mission = "combat"
										
							
						elif ship.mission == "combat_escort":
							travel_target = escort_target.position + escort_target.velocity * 0.3
							travel_target = travel_target + escort_index * Vector2(sin(escort_target.rotation) , -cos(escort_target.rotation) ) * (400)
							escort_protocol()
							
							var current_target_priority = 3
							for i in battle.shipnodes:
								
								if i.faction != ship.faction and i.status == "alive":
									if calculate_target_priority(i) <= current_target_priority:
										ship.target = i
										ship.mission = "combat"
						
						
						elif ship.mission == "unload":
							
							if travel_target.distance_to(Vector2(0,0)) > 165:
								var xx = (battle.rg.randf() - 0.5) * 330
								var yy = (battle.rg.randf() - 0.5) * 330
								travel_target = Vector2(xx , yy)	
								
								
								
							if ship.position.distance_to(Vector2(0,0)) < battle.unloadradius:
								
								ship.mission = "combat_travel"
								travel_target = ship.position + 30000 * Vector2(cos(ship.rotation), sin(ship.rotation))
								travel_protocol()
								
							else:							
								travel_protocol()
								
						elif ship.mission == "load":
							
							if travel_target.distance_to(Vector2(0,0)) > 165:
								var xx = (battle.rg.randf() - 0.5) * 330
								var yy = (battle.rg.randf() - 0.5) * 330
								travel_target = Vector2(xx , yy)	
								
								
								
							if battle.mass == 0 or ship.get_capacity() == 0:
								ship.mission = "combat"
							else:							
								travel_protocol()
								
								
								
						
								
						elif ship.mission == "exit":
							exiting_protocol()
							if abs(ship.position.x) > 50000 or abs(ship.position.y) > 50000:
								ship.status = "stranded"
							
						
						if ship.mission == "combat":
							
							if ship.threatstatus == false:
								ship.mission = "exit"
								return
							
							#print("cancelling target")
							var current_target_priority = calculate_target_priority(ship.target) / 1.01
							for i in battle.shipnodes:
								#print(calculate_target_priority(i))
								if i.faction != ship.faction and i.status == "alive":
									if calculate_target_priority(i) <= current_target_priority:
										ship.target = i
										
										
							if ship.target == ship:
								if search_started == false:
									search_started = true
									var direction = battle.rg.randf() * 2 * PI
									travel_target = Vector2(cos(battle.rg.randf() * 2 *PI), sin(battle.rg.randf() * 2 *PI)) * 50000
								if ship.position.distance_to(travel_target) < 1000:
									var direction = battle.rg.randf() * 2 * PI
									travel_target = Vector2(cos(battle.rg.randf() * 2 *PI), sin(battle.rg.randf() * 2 *PI)) * 50000
								travel_protocol()
								return
							
							if ship.target.status == "stranded":
								ship.target = ship
								
							
							
							
							
							
							
							
							#Decide Speed
								
							if abs(ship.get_angle_to(ship.target.position)) < 30 * PI/180 and ship.position.distance_to(interception_course()) > ship.effective_range * 0.5 * ship.speed / (ship.target.speed + 0.0001):
								ai_boost = "accelerate"
										
							elif abs(ship.get_angle_to(ship.target.position)) < 30 * PI/180 and ship.position.distance_to(interception_course()) < ship.effective_range * 0.6:
								ai_boost = "deccelerate"
	#						elif abs(ship.target.get_angle_to(ship.position)) < 30 * PI/180 and ship.position.distance_to(interception_course()) < 2000 * ship.speed / (ship.target.speed + 0.001):
	#							ai_boost = "accelerate"
							else:
								ai_boost = "steady"
							
							# Decide Power Ratio:
							
							if protocol == "pursuit":
								if abs(ship.get_angle_to(ship.target.position)) < 30 * PI/180:
#									if ship.position.distance_to(ship.target.position) > ship.effective_range *4:
#										ship.target_power_ratio = pow(ship.position.distance_to(ship.target.position) , 0.5) / 100
									if ship.position.distance_to(ship.target.position) > ship.effective_range and ship.target_power_ratio < 0.85 and ship.position.distance_to(ship.target.position)/(ship.speed - ship.target.speed + 0.00000001) < 5:
										ship.target_power_ratio = ship.target_power_ratio + 0.05
									elif ship.position.distance_to(ship.target.position) < ship.effective_range / 2 and ship.target_power_ratio > 0.15:
										ship.target_power_ratio = ship.target_power_ratio - 0.05
										
									check_missile_target()
								else: 
									ship.target_power_ratio = 0.4
							
							elif protocol == "evade":
								if ship.position.distance_to(ship.target.position) < 2500:
									ship.target_power_ratio = 0.9
								else:
									ship.target_power_ratio = 0.5
									
								
									
							elif protocol == "travel":
								ship.target_power_ratio = 0.5
							
							if ship.target_power_ratio > 0.9:
								ship.target_power_ratio = 0.9
							elif ship.target_power_ratio < 0.1:
								ship.target_power_ratio = 0.1
							
							
							
												
							# Decide which way to turn:
							
							
													
							if turn_time(ship, ship.get_angle_to(ship.target.position)) < 15 * PI/180:
								if Input.is_key_pressed(KEY_M):
									print(ship.ship["name"] + " pursue1 " + ship.target.ship["name"])
								pursuit_protocol()
									
							elif turn_time(ship, ship.get_angle_to(ship.target.position)) <= threat_time(ship, ship.target) + 0.5:
								if Input.is_key_pressed(KEY_M):
									print(ship.ship["name"] + " pursue2 " + ship.target.ship["name"])
								pursuit_protocol()
							elif ship.position.distance_to(ship.target.position) < 3000:
								#print("evade")
								if Input.is_key_pressed(KEY_M):
									print(ship.ship["name"] + " evade" )
								evade_time = evade_time + delta * 30
								evade_protocol()
								
			
							 
						
							
							
			
				
			
				
					
		elif ship.control == "Player":
			player_control()	
			
		elif ship.towee[0] != ship:
				if ship.towee[1].data[3] == "destroyed":
						ship.mission = "combat"
						ship.towee = [ship, ship]	
				else:
					ship.position = ship.towee[1].get_global_position()
					ship.set_z_index(0)
					ship.rotation = ship.towee[0].rotation + PI
			
			
			
func evade_protocol():
	protocol = "evade"
	if left.is_colliding() or right.is_colliding() or left2.is_colliding() or right2.is_colliding():
		#print("something")
		if left.is_colliding() and right.is_colliding() == false:
			#print("left_only")
			ai_turn = "right"
		elif right.is_colliding() and left.is_colliding() == false:
			ai_turn = "left"
			#print("right_only")
		elif left.is_colliding() and right.is_colliding():
			#print("both_only")
			for i in range(180):
				left.rotation = left.rotation - PI/180
				left.force_raycast_update()
				if left.is_colliding() == false:
					ai_turn = "left"
					break
				right.rotation = right.rotation + PI/180
				right.force_raycast_update()
				if right.is_colliding() == false:
					ai_turn = "right"
					break
		elif left2.is_colliding() and right2.is_colliding():
			#print("happening")
			for i in range(180):
				left2.rotation = left2.rotation - PI/180
				left2.force_raycast_update()
				if left2.is_colliding() == false:
					ai_turn = "left"
					break
				right.rotation = right2.rotation + PI/180
				right2.force_raycast_update()
				if right2.is_colliding() == false:
					ai_turn = "right"
					break
	
	
	elif evade_time > 2:
		if (ship.speed + ship.boost_rate * 120) > (ship.target.speed + ship.target.boost_rate * 120):
			ai_boost = "accelerate"
			ship.target_power_ratio = 0.9
			
		elif (ship.speed - ship.boost_rate * 30) < (ship.speed - ship.boost_rate * 30):
			ai_boost = "deccelerate"
			ship.target_power_ratio = 0.5	
			#print("slow_ambush")
		else:
			ship.target_power_ratio = 0.1	
			target_angle = ship.rotation + PI/2
			#print("spin")
			
	
	
	
	
	else:
		if ship.position.distance_to(ship.target.position) < laser_range / 4:
			#var anglediff = angle_difference(ship.rotation, ship.target.rotation)
			target_angle = ship.target.rotation + PI
			if Input.is_key_pressed(KEY_M):
				print(ship.ship["name"] + " evading by turn" )

		else:
			target_angle = ship.get_angle_to(ship.target.position) + ship.rotation + PI
			if Input.is_key_pressed(KEY_M):
				print(ship.ship["name"] + " fleeing" )
				print(evade_time)
#		
	
			

func exiting_protocol():
	protocol = "exit"
	
	if ship.position.distance_to(Vector2(0,0)) < ship.battle.missileradius:
		ai_boost = "accelerate"
		ship.target_power_ratio = 0.9
	else:
		var circle_edge = Vector2(cos(ship.rotation), sin(ship.rotation)) * 50000
		var pointed_distance = circle_edge.distance_to(ship.position)
		var time_to_exit = pointed_distance / 1800
		
		var direction_to_edge = ship.position.angle() #atan2(ship.position.y, ship.position.x)
		var distance_to_edge = (Vector2(cos(direction_to_edge), sin(direction_to_edge)) * 50000).distance_to(ship.position)
		var turn_time = turn_time(ship, angle_difference(ship.rotation, direction_to_edge))
		
		if distance_to_edge/1800 + turn_time < time_to_exit:
			target_angle = direction_to_edge
			ai_boost = "accelerate"
			ship.target_power_ratio = 0.9
		else:
			ai_boost = "accelerate"
			ship.target_power_ratio = 0.9
	
	

func pursuit_protocol():	
		evade_time = 0
		protocol = "pursuit"
		if ship.target != ship:
			target_angle = ship.get_angle_to(interception_course()) + ship.rotation
		else:
			protocol = "none"
			ship.mission = "combat"
			
		
			
func travel_protocol():
		protocol = "travel"		
		target_angle = ship.get_angle_to(travel_target) + ship.rotation
		if ship.position.distance_to(travel_target) < 50:
			ai_boost = "deccelerate"
		elif ship.mission != "combat_escort":
			
			if ship.position.distance_to(travel_target) / (ship.speed + 0.000001 ) - ( ship.speed - 30 * ship.boost_rate )/ (ship.boost_rate * 60 + 0.01) > 1:
				ai_boost = "accelerate"
			elif ship.position.distance_to(travel_target) / (ship.speed +0.01 + 30 * ship.boost_rate) - ship.speed / (ship.boost_rate * 60 + 0.01) < 0.1:
				ai_boost = "deccelerate"
			else:
				ai_boost = "steady"
				
		elif ship.position.distance_to(travel_target) / (ship.speed + 0.000001 ) - ( ship.speed - escort_target.speed )/ (ship.boost_rate * 60 + 0.01) > 0.2:
			ai_boost = "accelerate"
		elif  ship.position.distance_to(travel_target) / (ship.speed +0.000001 ) - (ship.speed - escort_target.speed) / (ship.boost_rate * 60 + 0.01) < 0.1:
			ai_boost = "deccelerate"
			
		else:
			ai_boost = "steady"
			
func escort_protocol():
		protocol = "travel"		
		target_angle = ship.get_angle_to(travel_target) + ship.rotation
		ship.target_power_ratio = escort_target.target_power_ratio + 0.05
		if ship.position.distance_to(travel_target) < 150:
			target_angle = escort_target.rotation
			if ship.speed > escort_target.speed:
				ai_boost = "deccelerate"
			elif ship.speed < escort_target.speed - 30 * ship.boost_rate:
				ai_boost = "accelerate"
			else:
				ai_boost = "steady"
		else:
			travel_protocol()
			
						
						
func turn_time(ship, arc):
	return abs(arc / (ship.turn_rate + 0.001) / 60)
	
func threat_time(ship, threat):
	if threat.position.distance_to(ship.position) > laser_range:
		return turn_time(threat, threat.get_angle_to(ship.position)) + (threat.position.distance_to(ship.position) - laser_range) / (threat.speed + 0.001) 
	else:
		return turn_time(threat, threat.get_angle_to(ship.position))
		
		
func player_control():
	if Input.is_key_pressed(KEY_A):
		battle.rpc("turn_left", ship.shipid)
		turn_history2.remove(0)
		turn_history2.append(1)
	elif Input.is_key_pressed(KEY_D):
		battle.rpc("turn_right", ship.shipid)
		turn_history2.remove(0)
		turn_history2.append(-1)
	else:
		battle.rpc("turn_center", ship.shipid)
		turn_history2.remove(0)
		turn_history2.append(0)
		
	if ship.max_speed < ship.speed:
		battle.rpc("deccelerate", ship.shipid)
		#print("forced_dec")	
	elif Input.is_key_pressed(KEY_W) and ship.max_speed > ship.speed + ship.boost_rate :
		battle.rpc("accelerate", ship.shipid)
	elif Input.is_key_pressed(KEY_S):
		battle.rpc("deccelerate", ship.shipid)
	
	
		
	if Input.is_key_pressed(KEY_1):
		ship.target_power_ratio = 0.1
	elif Input.is_key_pressed(KEY_2):
		ship.target_power_ratio = 0.2
	elif Input.is_key_pressed(KEY_3):
		ship.target_power_ratio = 0.3
	elif Input.is_key_pressed(KEY_4):
		ship.target_power_ratio = 0.4
	elif Input.is_key_pressed(KEY_5):
		ship.target_power_ratio = 0.5
	elif Input.is_key_pressed(KEY_6):
		ship.target_power_ratio = 0.6
	elif Input.is_key_pressed(KEY_7):
		ship.target_power_ratio = 0.7
	elif Input.is_key_pressed(KEY_8):
		ship.target_power_ratio = 0.8
	elif Input.is_key_pressed(KEY_9):
		ship.target_power_ratio = 0.9
		
	battle.rpc("set_target_power_ratio",ship.shipid, ship.target_power_ratio)

		
func angle_difference(angle1, angle2):
	
	while angle1 >= 2*PI:
		angle1 = angle1 - 2*PI
	while angle1 < 0:
		angle1 = angle1 + 2*PI
	while angle2 >= 2*PI:
		angle2 = angle2 - 2*PI
	while angle2 < 0:
		angle2 = angle2 + 2*PI
	
#	print(angle1)
#	print(angle2)
	
	var diff = (angle1 - angle2)
	if diff > 0 and diff < PI:
		return -diff
	elif diff > 0 and diff > PI:
		return 2*PI - diff
	elif diff < 0 and diff > -PI:
		return -diff
	elif diff < 0 and diff < -PI:
		return -(2*PI + diff) 
	else:
		return 0
	
func calculate_target_priority(possible_target):
	var angle = ship.get_angle_to(possible_target.position)
	
	var priority = turn_time(ship, angle)
	
	if possible_target.status == "stranded":
		priority = 10000000000
	elif possible_target.detected_by.has(ship.faction) == false:
		priority = 10000000000
	
	elif ship.position.distance_to(possible_target.position) > ship.effective_range:
		priority = priority + (ship.position.distance_to(possible_target.position) - ship.effective_range)/(ship.speed + 1)
		
		
	return priority
	
func check_missile_target():
	if ship.get_angle_to(ship.target.position) < PI/180 * 30:
		if ship.position.distance_to(ship.target.position) < 4000:
			if ship.position.distance_to(ship.target.position) > 500:
				if ship.target.hulls > 1:
					if abs(angle_difference(ship.rotation, ship.target.rotation)) < PI/180 * 90:
						ship.fire_missile(ship.target)
	
func pick_new_target():
	#Get a list of ships that we are allowed to seek.
	
	
	
	var primaryshiptargets = []
	var secondaryshiptargets = []
	for i in battle.shipnodes:
		if i.status == "alive" and  i.faction != ship.faction:
			primaryshiptargets.append(i)
		elif i.status == "alive" and  i.faction != ship.faction :
			secondaryshiptargets.append(i)
	
			
	
	var targets = []
	var numtargets = 0
	if primaryshiptargets.size() > 0:
		numtargets = primaryshiptargets.size()
		targets = primaryshiptargets
	elif secondaryshiptargets.size() > 0:
		numtargets = secondaryshiptargets.size()
		targets = secondaryshiptargets
	if numtargets > 0:
		var rng = battle.rg.randi() % numtargets
		
		return targets[rng]
	else:
		return ship	
		
		
		
func interception_course():
	var time_to_target = 0
	if ship.position.distance_to(ship.target.position) > 22000:
		
		
		var h1 = ship.target.velocity.dot(ship.target.velocity) - ship.speed * ship.speed + 0.00001
		var h2 = ship.target.velocity.dot(ship.target.position - ship.position) - ship.effective_range * ship.speed
		var h3 = (ship.target.position - ship.position).dot(ship.target.position - ship.position) - ship.effective_range * ship.effective_range
		
		
		
		
		
		if (h2/h1)*(h2/h1) - h3/h1 < 0:
			time_to_target = 0
		elif -(h2/h1) + pow((h2/h1)*(h2/h1) - h3/h1, 0.5) > 0:
			time_to_target = -(h2/h1) + pow((h2/h1)*(h2/h1) - h3/h1, 0.5)
			if -(h2/h1) - pow((h2/h1)*(h2/h1) - h3/h1, 0.5) > 0:
				time_to_target = -(h2/h1) - pow((h2/h1)*(h2/h1) - h3/h1, 0.5)
				
		
		
	else:
		time_to_target = 0	
	
	return ship.target.position + ship.target.velocity * time_to_target 
	
	
	
func avoid_obstacles():
	var dodge_response = "none"
	if left.is_colliding() or right.is_colliding() or left2.is_colliding() or right2.is_colliding():
		#print("something")
		if left.is_colliding() and right.is_colliding() == false:
			#print("left_only")
			dodge_response = "right"
		elif right.is_colliding() and left.is_colliding() == false:
			dodge_response = "left"
			#print("right_only")
		elif left.is_colliding() and right.is_colliding():
			#print("both_only")
			for i in range(180):
				left.rotation = left.rotation - PI/180
				left.force_raycast_update()
				if left.is_colliding() == false:
					dodge_response = "left"
					break
				right.rotation = right.rotation + PI/180
				right.force_raycast_update()
				if right.is_colliding() == false:
					dodge_response = "right"
					break
		elif left2.is_colliding() and right2.is_colliding():
			#print("happening")
			for i in range(180):
				left2.rotation = left2.rotation - PI/180
				left2.force_raycast_update()
				if left2.is_colliding() == false:
					dodge_response = "left"
					break
				right.rotation = right2.rotation + PI/180
				right2.force_raycast_update()
				if right2.is_colliding() == false:
					dodge_response = "right"
					break
#	if ship.ship["name"] == "Shuttle":
#		print(ship.mission)
	return dodge_response
	

	
	

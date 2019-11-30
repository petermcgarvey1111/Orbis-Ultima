extends Node2D

var data = []
#onready var type = data[0]
onready var target = get_parent()
var reload = 0.1
var magazine = 1000
onready var battle = get_node("../..")
onready var shot_asset = preload("res://shot.tscn")
onready var mech_asset = preload("res://mech.tscn")
#onready var state = data[3]
var number = 0
var componentid = 0


onready var unloadradius = battle.unloadradius
onready var turretradius = battle.turretradius
onready var missileradius = battle.missileradius
onready var combatradius = battle.missileradius
onready var pursuitradius = battle.pursuitradius
onready var deepradius = battle.deepradius
onready var exitradius = battle.exitradius
onready var delta2 = battle.delta2
onready var time_mod = battle.time_mod
onready var this_ship = get_parent()
var firetable = []
var home_angle = 0

var lag_delay = 15




func _ready():
	
	home_angle = data[4] * PI/180
	$friendly_check.add_exception(this_ship.get_node("Area2D"))
	
	
	if data[0] == "laser" or data[0] == "glaser":
		$red_laser.queue_free()
	else:
		$friendly_check.queue_free()
		
	
		
	if get_node("../../../designdata").firetable.has(data[0]):
		firetable = get_node("../../../designdata").firetable[data[0]]


func pick_new_target(type, mode):
	#Get a list of ships that we are allowed to fire on.
	var primaryshiptargets = []
	var secondaryshiptargets = []
	for i in battle.shipnodes:
		if i.status == "alive" and  i.faction != this_ship.faction and this_ship.position.distance_to(target.position) < firetable[5] and abs(this_ship.get_angle_to(target.position)) < firetable[6]:
			primaryshiptargets.append(i)
		elif i.status == "alive" and  i.faction != this_ship.faction and this_ship.position.distance_to(target.position) < firetable[5] and abs(this_ship.get_angle_to(target.position)) < firetable[6]:
			secondaryshiptargets.append(i)
			
	#Get a list of mechs that we are allowed to fire on.
	var possiblemechtargets = []
	for i in battle.mechs:
		if i.faction != this_ship.faction and i.status != "dead":
			possiblemechtargets.append(i.mechid)
			
	if type == "ship":
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
			return this_ship	
	
	if type == "bombmech":
		var targets = []
		var numtargets = 0
		if possiblemechtargets.size() > 0:
			numtargets = possiblemechtargets.size()
			targets = possiblemechtargets
			var rng = battle.rg.randi() % numtargets
			return battle.mechs[targets[rng]]
		else:
			return this_ship	
	

func _physics_process(delta):
	lag_delay = battle.lag_delay
	delta = delta2 * time_mod
	#print(get_parent().position)
	if battle.battle_paused == false:
		
		if data[3] == "ready" and firetable.size() > 0:
				
				if target == this_ship or this_ship.position.distance_to(target.position) > firetable[5] or target.status == "dead" or magazine < 1 or abs(this_ship.get_angle_to(target.position)) > firetable[6] *PI/180:
					if data[0] == "laser":
						target = pick_new_target("ship","random")
						magazine = 10
						battle.assign_target( this_ship.shipid, componentid, target.shipid)
					elif data[0] == "glaser":
						target = pick_new_target("ship","random")
						battle.assign_target( this_ship.shipid, componentid, target.shipid)
					elif data[0] == "rlaser":
						target = pick_new_target("ship","random")
						battle.assign_target( this_ship.shipid, componentid, target.shipid)
					elif data[0] == "bombs" and this_ship.position.distance_to(battle.core) < unloadradius + 5:
						target = pick_new_target("bombmech","random")
						if target != this_ship:
							battle.assign_target_ground(this_ship.shipid, componentid, target.mechid)
						
	
	
		if data[3] == "ready" and data[0] != "storage":
			
			if data[0] == "laser" or data[0] == "glaser" or data[0] == "rlaser":
				reload = reload - delta
				
				if target !=  this_ship:
					
					rotation = home_angle
					if abs(get_angle_to(ballistics())) < 30 * PI / 180:
						
						look_at(ballistics())
					
					if reload < 0 and abs(get_angle_to(ballistics())) < (PI / 180 * 10) and this_ship.position.distance_to(target.position) < firetable[5]:					
						
						if data[0] == "laser" or data[0] == "glaser":
							var first_col = $friendly_check.get_collider()
							if first_col != null:
								if first_col.get_parent().faction != this_ship.faction:
									fire_weapon(data[0])
									magazine = magazine - 1
							else:
								fire_weapon(data[0])
								magazine = magazine - 1
						elif data[0] == "rlaser":
							
							if not $Sound.is_playing():
								$Sound.play(0.0)
							
							$red_laser.show()
							$red_laser/red_ray.set_enabled(true)
							$red_laser/red_ray.set_cast_to(Vector2(125, 0))
							$red_laser/red_ray.force_raycast_update()
							$red_laser/red_ray.add_exception(this_ship.get_node("Area2D"))
							var rng = (battle.rg.randf() - 0.5) / 2
							$red_laser.modulate = Color(1 +rng, 1 + rng, 1 + rng, 1)
							var collider = $red_laser/red_ray.get_collider()
							if collider != null:
								if collider.get_parent().faction != this_ship.faction:
									if (get_tree().is_network_server()):
										battle.rpc("queue_burn", battle.battletimer + lag_delay, collider.get_parent().shipid, firetable[1])
									#collider.get_parent().burn(firetable[1])
								while $red_laser.scale.x * 125 > (position + this_ship.position).distance_to(collider.get_parent().position):
									$red_laser.scale.x = $red_laser.scale.x - 0.4
								$red_laser.scale.x = $red_laser.scale.x + 0.4
							else:
								$red_laser.scale.x = $red_laser.scale.x + 0.4
								
							
							
#							if reload < -1:
#								reload = firetable[0]
#								$red_laser.hide()
#							elif reload < 0:
#								if $red_laser.scale.x > 1:
#									$red_laser.scale.x = $red_laser.scale.x - 1
				
				elif data[0] == "rlaser":
					
					if $red_laser.scale.x > 0.4:
						$red_laser.scale.x = $red_laser.scale.x - 0.4
					else:
					#reload = firetable[0]
						$red_laser.hide()
					
			
			elif data[0] == "bombs" and data[2] > 0:
				
				reload = reload - delta
				if target !=  this_ship:
					
					if reload < 0:
						
						fire_weapon(data[0])
						data[2] = data[2] -1
						if data[2] == 1:
							$Sprite.texture = load("res://Components/1bomb.png")
						elif data[2] == 0:
							$Sprite.texture = load("res://Components/0bombs.png")
			
			
			
			
		elif data[0] == "storage" and get_parent().position.distance_to(Vector2(0,0)) <= unloadradius:	
			
			if data[3] == "ready" or data[3] == "mass":
				
				if data[2] < 10 and get_node("../..").mass > 0:
					#print("attempting to load")
					if 1 == 1: #(get_tree().is_network_server()):
						if battle.rg.randf() < 2 * delta:
							battle.loadmass( get_parent().shipid, componentid)
							
		
			
						
			elif data[3] == "mech" and get_parent().position.distance_to(Vector2(0,0)) <= unloadradius:
				data[3] = "ready"
				$Sprite.texture = load("res://Components/storage.png")
				$Sprite.modulate = Color(1,1,1,1)
				var newmech = mech_asset.instance()
				newmech.faction = get_parent().faction
				newmech.position = get_parent().position
				newmech.spawnorder = 1000 + get_parent().numunloaded
				get_parent().numunloaded = get_parent().numunloaded + 1
				newmech.mechid = battle.mechs.size()
				battle.mechs.append(newmech)
				battle.get_node("battlefield").add_child(newmech) 
				
			elif data[3] == "2mechs" and get_parent().position.distance_to(Vector2(0,0)) <= unloadradius:
				data[3] = "mech"
				$Sprite.texture = load("res://Components/mech.png")
				var newmech = mech_asset.instance()
				newmech.faction = get_parent().faction
				newmech.position = get_parent().position
				newmech.spawnorder = 1000 + get_parent().numunloaded
				get_parent().numunloaded = get_parent().numunloaded + 1
				newmech.mechid = battle.mechs.size()
				battle.mechs.append(newmech)
				battle.get_node("battlefield").add_child(newmech) 
				
			elif data[3] == "amech" and get_parent().position.distance_to(Vector2(0,0)) <= unloadradius:
				data[3] = "ready"
				$Sprite.texture = load("res://Components/storage.png")
				$Sprite.modulate = Color(1,1,1,1)
				var newmech = mech_asset.instance()
				newmech.mechid = battle.mechs.size()
				battle.mechs.append(newmech)
				newmech.faction = get_parent().faction
				newmech.type = "amech"
				newmech.position = get_parent().position
				newmech.spawnorder = 1000 + get_parent().numunloaded
				get_parent().numunloaded = get_parent().numunloaded + 1
				battle.get_node("battlefield").add_child(newmech) 
				
			elif data[3] == "mmech" and get_parent().position.distance_to(Vector2(0,0)) <= unloadradius:
				data[3] = "ready"
				$Sprite.texture = load("res://Components/storage.png")
				$Sprite.modulate = Color(1,1,1,1)
				var newmech = mech_asset.instance()
				newmech.type = "mmech"
				newmech.faction = get_parent().faction
				newmech.position = get_parent().position
				newmech.spawnorder = 1000 + get_parent().numunloaded
				get_parent().numunloaded = get_parent().numunloaded + 1
				newmech.mechid = battle.mechs.size()
				battle.mechs.append(newmech)
				battle.get_node("battlefield").add_child(newmech) 
				
		process_animation(delta)

func fire_weapon(weapon):
	$Sound.stream = load("res://Sounds/" + data[0] + ".wav")
	$Sound.play(0.0)
	var newshot = shot_asset.instance()
	newshot.position = get_global_position() 
	newshot.target = target
	newshot.get_node("Sprite").texture = load(firetable[3])
	newshot.parent = this_ship
	newshot.accuracy = firetable[1]
	newshot.weapontype = firetable[2]
	newshot.speedmult = firetable[4]
	newshot.target_projection = ballistics()
	newshot.hide()
	newshot.variance = battle.rg.randf()
	battle.add_child(newshot)
	reload = firetable[0]
	
	if weapon == "missile":
		newshot.rotation = rotation + get_parent().rotation
		data[2] = data[2] - 1
		get_node("Sprite").texture = load("res://Components/0missile.png")
	
func destroy():
	#print(str(battle.physicstimer) + "hittime")
	$Sound.stream = load("res://Sounds/explosion.wav")
	$Sound.play(0.0)
	data[3] = "destroyed"
	$Sprite.modulate = Color(1,0.3,0.3,1)
	if data[0] == "engine" or "booster":
		get_parent().check_mobility()
	if data[0] == "hull":
		if get_parent().hulls != 0:
			get_parent().hulls = get_parent().hulls - 1
			get_parent().check_hulls()
	if data[0] == "laser" or "glaser":
		get_parent().check_threat()
	$flash.set_emitting(true)
	$flash.show()
	
	#$flash.modulate = Color(1, 3, 3, 1)
	
func process_animation(delta):
	if data[0] == "engine" and data[3] == "ready":
		$blast.show()
		$blast.scale.x = get_parent().speed / 1800 + 0.2
		var rng1 = 1 + (randf() / 2)
		var rng2 = 1 + (randf() / 2)
		var rng3 = 1 + (randf() / 2)
		$blast.modulate = Color(rng1, rng2, rng3, 1)
	elif data[0] == "booster" and data[3] == "ready":
		$blast.show()
		$blast.scale.x = get_parent().speed / 1800 + 0.2
		var rng1 = 1 + (randf() / 2)
		var rng2 = 1 + (randf() / 2)
		var rng3 = 1 + (randf() / 2)
		$blast.modulate = Color(rng1, rng2, rng3, 1)
		reload = reload + delta
		if reload > 10:
			destroy()
	else:
		$blast.hide()
	
func ballistics():
	if target.type == "ship":
		var wep = firetable
		var shot_speed = wep[4]
		var distance = (position + this_ship.position).distance_to(target.position)
		var time_to_target = distance / shot_speed
		var target_projection = target.position + target.velocity * time_to_target
		time_to_target = (position + this_ship.position).distance_to(target_projection) / shot_speed 
		target_projection = target.position + target.velocity * time_to_target
		time_to_target = (position + this_ship.position).distance_to(target_projection) / shot_speed 
		
		var turn_ratio = 0
		for i in target.get_node("navigation").turn_history:
			turn_ratio = turn_ratio + i
		turn_ratio = turn_ratio / target.get_node("navigation").turn_history.size()
		
		var newrotation = target.rotation - time_to_target * 60 * target.turn_rate * turn_ratio / 2
		var newvelocity =  Vector2(cos(newrotation), sin(newrotation)) * target.speed
		return target.position + newvelocity * time_to_target
	
	else:
		return target.position
	


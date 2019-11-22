extends Area2D

var target = Vector2(0,0)
var parent = "none"
var speed = 0
var weapontype = "none"
var accuracy = 100
var rng = 0
var life = 22
var speedmult = 1000
onready var battle = get_parent()
var missilerot = 0
var turnrad = 1.5
var target_projection = Vector2(0,0)
var variance = 0
onready var delta2 = battle.delta2
var lag_delay = 15

func _ready():
	if weapontype == "missile":
		rng = 100
		show()
	else:
		rng = battle.rg.randf() * 40
		show()
	

	
	add_to_group("shots")
#	if weapontype == "all":
#		$redtrace.set_emitting(true)
	
	if weapontype == "missile":
		$Sprite.texture = load("res://Shots/missile.png")
		$blast.show()
		rotation = missilerot
		$trail.set_emitting(true)
		life = 100
	
	else:
		if target.type == "ship":
			look_at(target_projection)
		else:
			look_at(target.position)
		rotation = rotation + PI/180 * (variance -0.5) * 5
		speed = Vector2(cos(rotation), sin(rotation))
		
	if parent.type == "mmech":
		look_at(target.get_global_position())

func _physics_process(delta):
	delta = delta2
	if battle.battle_paused == false:
		life = life - delta
		$trail.set_speed_scale(1)
				
		if weapontype == "missile":
			if life > 0.5:
				if get_angle_to(target.get_global_position()) > 0 + PI/180:
					rotation = rotation + delta / turnrad
				if get_angle_to(target.get_global_position()) < -PI/180:
					rotation = rotation - delta / turnrad
				speed = Vector2(cos(rotation), sin(rotation))
				position = position + speed * delta * speedmult
				turnrad = turnrad - delta/30
				
			elif life < 0 and weapontype != "bomb":
				queue_free()
				
			var rng1 = 1 + (randf() / 2)
			var rng2 = 1 + (randf() / 2)
			var rng3 = 1 + (randf() / 2)
			$blast.modulate = Color(rng1, rng2, rng3, 1)
			scale = target.scale
		
		else:
			
			if life > 0.5:
				
				position = position + speed * delta * speedmult
				#print((speed * delta * speedmult).length())
			
			if life < 0 and weapontype != "bomb":
				queue_free()
			if weapontype == "bomb":
				scale = scale * 0.999 * delta * 60
				
	else:
		$trail.set_speed_scale(0)	
	

func _on_shot_area_entered(area):
	
	if area.get_parent().faction != parent.faction:
		
		if 1 == 1: #(get_tree().is_network_server()):
			if target.type == "ship":
				#var rng2 = battle.rg.randf() * pow(target.speed, 0.5)
				#var rng3 = battle.rg.randf() * 40
				if rng > pow(target.speed, 0.5) / 2:
					$Sound.stream = load("res://Sounds/smallexp.wav")
					$Sound.play(0.0)
					$sparks.set_emitting(true)			
					$Sprite.hide()
					$trail.hide()
					$blast.hide()
					life = 0.5
					if (get_tree().is_network_server()):
						if weapontype == "random":
							var rng = randf() * 100
							if rng < accuracy and target.hulls > 0:
								var destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay , target.shipid, destroy)
						elif weapontype == "heavy":
							var rng = randf() * 100
							if rng < accuracy and target.hulls > 0:
								
								var destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
								destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
						elif weapontype == "missile":
							var rng = randf() * 100
							if rng < accuracy and target.hulls > 0:
								
								var destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
							rng = randf() * 100
							if rng < accuracy and target.hulls > 0:
								
								var destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
							rng = randf() * 100
							if rng < accuracy and target.hulls > 0:
								
								var destroy = int(rand_range(0,target.componentnodes.size()-1))
								if target.componentnodes[destroy].data[0] != "hull":
									destroy = int(rand_range(0,target.componentnodes.size()-1))
								#battle.destroy_comp(target.shipid, destroy)
								battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
						elif weapontype == "all":
							for destroy in target.componentnodes.size():
								var rng = randf() * 100
								if rng < accuracy and target.hulls > 0:
									#battle.destroy_comp(target.shipid, destroy)
									battle.rpc("queue_destroy_comp", battle.battletimer + lag_delay, target.shipid, destroy)
								
				
				
				
				
					
			
			
			
			
			
			
			
			
			
			else:
				if area.get_parent() == target:
					$Sound.stream = load("res://Sounds/smallexp.wav")
					$Sound.play(0.0)
					if weapontype == "heavy":
						var rng = battle.rg.randf() * 100
						if rng < accuracy and target.status == "alive":
							battle.destroy_mech( target.mechid)
							$Sound.stream = load("res://Sounds/explosion.wav")
							$Sound.play(0.0)
					elif weapontype == "mech":
						var rng = battle.rg.randf() * 100
						if rng < accuracy and target.status == "alive":
							battle.destroy_mech( target.mechid)
							$Sound.stream = load("res://Sounds/explosion.wav")
							$Sound.play(0.0)
					elif weapontype == "bomb":
						var rng = battle.rg.randf() * 100
						if rng < accuracy and target.status == "alive":
							battle.destroy_mech( target.mechid)
							$Sound.stream = load("res://Sounds/explosion.wav")
							$Sound.play(0.0)
							
					$sparks.set_emitting(true)			
					$Sprite.hide()
					$trail.hide()
					$blast.hide()
					life = 0.5
					
						
				
					
		
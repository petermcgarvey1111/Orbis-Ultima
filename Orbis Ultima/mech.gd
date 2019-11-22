extends Node2D
var mechid = 0
var radius = 200
var angle = 0
var faction = "none"
var type = "mech"
var status = "alive"
var target = self
onready var battle = get_node("../..")
onready var battlefield = get_node("..")
onready var shot_asset = preload("res://shot.tscn")
var reload = 1
var lifetime = 0
var spawnorder = 1000

onready var unloadradius = battle.unloadradius
onready var turretradius = battle.turretradius
onready var missileradius = battle.missileradius
onready var combatradius = battle.missileradius
onready var pursuitradius = battle.pursuitradius
onready var deepradius = battle.deepradius
onready var exitradius = battle.exitradius



func _ready():
	
	if spawnorder > 1000:
		var newposition = ((position - Vector2(0, 0)) /1.2)
		position = newposition
		var normal = position.normalized()
		var newnormal = Vector2(-normal.y, normal.x)
		position = position + newnormal * (spawnorder - 1000) * 20
			
			
			
	elif spawnorder > 24:
		radius = 110
		angle =  (spawnorder-24) * PI/180 * 11
		var direction = Vector2(cos(angle), sin(angle))
		position = direction * radius
	elif spawnorder > 6:
		radius = 70
		angle =  (spawnorder-6) * PI/180 * 20
		var direction = Vector2(cos(angle), sin(angle))
		position = direction * radius
	elif spawnorder > 0:
		radius = 35
		angle =  (spawnorder) * PI/180 * 60
		var direction = Vector2(cos(angle), sin(angle))
		position = direction * radius
			
	
	
	
	
	
	if faction != "none":
		$Sprite.modulate = Color(gamestate.factions[faction]["char_color"])
	
	if type == "amech":
		get_node("Sprite").texture = load("res://Components/amech.png")
	elif type == "mmech":
		get_node("Sprite").texture = load("res://Components/mmech.png")
		

func _physics_process(delta):
	if battle.battle_paused == false:
		
		
		
			
		
		if status == "alive":
			reload = reload - delta * battle.rg.randf() * 2
			if type == "mmech":
				if target.type != "ship" or position.distance_to(target.position) > battle.missileradius:
					target = pick_new_target("mmech", 0)
					
					if target.type == "ship":
						battle.assign_target_mmech(mechid, target.shipid)
					else:
						battle.assign_target_mech(mechid, target.mechid)
				elif target.radius > missileradius:
					target = pick_new_target("mmech", 0)
					
					if target.type == "ship":
						battle.assign_target_mmech(mechid, target.shipid)
					else:
						battle.assign_target_mech(mechid, target.mechid)
				
			if target == self:
				if 1 == 1: #(get_tree().is_network_server()):
					target = pick_new_target("mech", 0)
					var rng = battle.rg.randf() * delta * 0.1
					battle.assign_target_mech(mechid, target.mechid)
#					var newtarget = battle.rg.randi() % battle.mechs.size()
#					if faction != battle.mechs[newtarget].faction:
#						var rng = battle.rg.randf() * delta * 0.1
#						battle.assign_target_mech(mechid, target.mechid, rng)
#						#target = battle.mechs[newtarget]
						
			elif target.status == "alive" and reload < 0:
				$Sound.stream = load("res://Sounds/laser.wav")
				$Sound.play(0.0)
				var newshot = shot_asset.instance()
				newshot.position = self.get_global_position() 
				newshot.target = target
				newshot.get_node("Sprite").texture = load("res://Shots/lasershot.png")
				newshot.parent = self
				newshot.weapontype = "mech"
				#newshot.speedmult = 3000
				if type == "mech":
					newshot.accuracy = 3
					reload = 0.5
				elif type == "amech":
					newshot.accuracy = 3
					reload = 0.18
					#newshot.get_node(Sprite).modulate = Color(1,0.5,0.5,1)
				elif type == "mmech" and target.type == "ship":
					newshot.weapontype = "missile"
					newshot.accuracy = 30
					newshot.speedmult = 1000
					
					reload = 2
				elif type == "mmech":
					newshot.accuracy = 3
					reload = 0.5
					#newshot.get_node(Sprite).modulate = Color(0.5,1,0.5,1)
				newshot.hide()
				battle.add_child(newshot)
				
				
			elif target.status == "dead":
				target = self
				
func pick_new_target(type, mode):
	#Get a list of ships that we are allowed to fire on.
	var primaryshiptargets = []
	var secondaryshiptargets = []
	if type == "mmech":
		for i in battle.shipnodes:
			if i.status == "alive" and abs(i.position.distance_to(Vector2(0,0))) < missileradius and i.faction != faction and i.threatstatus == true:
				primaryshiptargets.append(i)
			elif i.status == "alive" and abs(i.position.distance_to(Vector2(0,0))) < missileradius and i.faction != faction:
				secondaryshiptargets.append(i)
	#Get a list of mechs that we are allowed to fire on.
	var possiblemechtargets = []
	for i in battle.mechs:
		if i.faction != faction and i.status != "dead":
			possiblemechtargets.append(i)
			
			
	if 1 == 1:
		var targets = []
		var numtargets = 0
		if primaryshiptargets.size() > 0:
			numtargets = primaryshiptargets.size()
			targets = primaryshiptargets
		elif secondaryshiptargets.size() > 0:
			numtargets = secondaryshiptargets.size()
			targets = secondaryshiptargets
		elif possiblemechtargets.size() > 0:
			numtargets = possiblemechtargets.size()
			targets = possiblemechtargets
		if numtargets > 0:
			var rng = battle.rg.randi() % numtargets
			return targets[rng]
		else:
			return self	
	



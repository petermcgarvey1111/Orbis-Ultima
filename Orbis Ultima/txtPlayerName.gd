extends LineEdit

func _ready():
	#randomize()
	var num = int(randf()*100)
	text = text + str(num)
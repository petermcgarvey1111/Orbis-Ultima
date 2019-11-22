extends Node2D

func _physics_process(delta):
    if not $Sound.is_playing():
        $Sound.play(0.0)
    print($Sound.is_playing())
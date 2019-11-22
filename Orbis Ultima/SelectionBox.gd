extends Sprite

var from = Vector2(0,0)
var to = Vector2(0,0)
var multi_select = false

func _ready():
	position = from

func _input_event(viewport, event, shape_idx): # Rectangle draw test
    if(event.type == InputEvent.MOUSE_BUTTON):
        if(event.button_index==1):
            if(event.is_pressed()):
                from  = event.pos
                to    = event.pos
                multi_select=true       
            else:
                multi_select=false      # done remove rect
                              # draw call without rect 
    elif(event.type == InputEvent.MOUSE_MOTION):    
        if(multi_select):                           
            to = event.pos  # update position and
                   # draw
				
    position = from
    scale.x = (to.x - from.x) / 500
    scale.y = (to.y - from.y) / 500

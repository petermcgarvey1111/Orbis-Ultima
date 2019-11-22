extends Camera2D

#Selectionstuff
var mousepos = Vector2()
var mouseposGlobal = Vector2()
var start = Vector2()
var end = Vector2()
var startv = Vector2()
var endv = Vector2()
var is_dragging = false 
#onready var rectd = get_node("../draw_rect")
onready var rectd = get_node("draw_rect")
onready var rectd2 = get_node("draw_rect2")
onready var rectd3 = get_node("draw_rect3")
onready var rectd4 = get_node("draw_rect4")
var controls_active = true

const MAX_ZOOM_LEVEL = 0.5
const MIN_ZOOM_LEVEL = 10
const ZOOM_INCREMENT = 0.05

signal moved()
signal zoomed()
signal area_selected()

var _current_zoom_level = 1
var _drag = false

func _ready ():
	var colortouse = $draw_rect.get_frame_color()
	$draw_rect4.set_frame_color(colortouse)
	$draw_rect2.set_frame_color(colortouse)
	$draw_rect3.set_frame_color(colortouse)
	
	
	set_process_input(true)
	connect("area_selected", get_node("../Battle"), "area_selected" , [self])

func _process(delta):
	if get_parent().sequence == "battle" :
		if Input.is_action_just_pressed("ui_but") and controls_active == true:
			start = mouseposGlobal
			startv = mousepos
			is_dragging = true
		if is_dragging and controls_active == true:
			end = mouseposGlobal
			endv = mousepos
			draw_area()
		if Input.is_action_just_released("ui_but"):
			if startv.distance_to(mousepos) > 20:
				end = mouseposGlobal
				endv = mousepos
				is_dragging = false
				draw_area(false)
				emit_signal("area_selected")
			else:
				end = start
				is_dragging = false
				draw_area(false)
	
	if Input.is_key_pressed(KEY_LEFT):
		set_offset(get_offset() + Vector2(-10,0) * _current_zoom_level) 
		
	elif Input.is_key_pressed(KEY_RIGHT):
		set_offset(get_offset() + Vector2(10,0) * _current_zoom_level) 
		
	if Input.is_key_pressed(KEY_DOWN):
		set_offset(get_offset() + Vector2(0,10) * _current_zoom_level ) 
		
	elif Input.is_key_pressed(KEY_UP):
		set_offset(get_offset() + Vector2(0,-10) * _current_zoom_level )
		
	


func draw_area(s = true):
	
	var pos = Vector2()
	var pos2 = Vector2()
	pos.x = min(start.x, end.x) - 960
	pos.y = min(start.y, end.y) - 540
	pos2.x = max(start.x, end.x) - 960
	pos2.y = max(start.y, end.y) - 540
	
	rectd.rect_size = Vector2(abs(start.x-end.x), abs(1*_current_zoom_level))
	rectd2.rect_size = Vector2(abs(1*_current_zoom_level), abs(start.y - end.y))
	rectd3.rect_size = Vector2(abs(1*_current_zoom_level), abs(start.y - end.y))
	rectd4.rect_size = Vector2(abs(start.x-end.x), abs(1*_current_zoom_level))
	rectd.rect_position = pos
	rectd2.rect_position = pos
	rectd3.rect_position = Vector2(pos2.x,pos.y)
	rectd4.rect_position = Vector2(pos.x,pos2.y)
		
	rectd.rect_size *= int(s)
	rectd2.rect_size *= int(s)
	rectd3.rect_size *= int(s)
	rectd4.rect_size *= int(s)


	

func _input(event):
	if event.is_action_pressed("cam_drag"):
        _drag = true
       
	elif event.is_action_released("cam_drag"):
        _drag = false
		
	
      
	elif event.is_action("cam_zoom_in"):
       
        _update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action("cam_zoom_out"):
       
        _update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
        set_offset(get_offset() - event.relative*_current_zoom_level)
        emit_signal("moved")
	elif event.is_action("cam_center"):
		if get_parent().clickstate != "battle":
	        set_offset(Vector2(0,0))
	        emit_signal("moved")
		else:
			for i in get_node("../Battle").shipnodes:
				if i.control == "Player" or i.control2 == "observed":
					set_offset(i.position + Vector2(-960, -540))
					emit_signal("moved")
					
	elif event is InputEventMouseMotion and get_parent().clickstate == "battle" and get_node("../Battle").battle_paused == false:
		pass
		#set_offset(get_offset() + event.relative*_current_zoom_level)
	
	if event is InputEventMouse:
		mousepos = event.position
		mouseposGlobal = get_global_mouse_position()
       

func _update_zoom(incr, zoom_anchor):
    var old_zoom = _current_zoom_level
    _current_zoom_level += incr
    if _current_zoom_level < MAX_ZOOM_LEVEL:
        _current_zoom_level = MAX_ZOOM_LEVEL
    elif _current_zoom_level > MIN_ZOOM_LEVEL:
        _current_zoom_level = MIN_ZOOM_LEVEL
    if old_zoom == _current_zoom_level:
        return
	
    
    var zoom_center = zoom_anchor - get_offset()
    var ratio = 1-_current_zoom_level/old_zoom
    set_offset(get_offset() + zoom_center*ratio)
    set_zoom(Vector2(_current_zoom_level, _current_zoom_level))
    emit_signal("zoomed")
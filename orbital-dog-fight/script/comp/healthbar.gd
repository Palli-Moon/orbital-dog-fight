
extends Node2D

var points

func _ready():
	var sx = -17
	var sy = -27
	var ex = 17
	var ey = -35
	var frame = get_node("Frame")
	frame.set_polygon(Vector2Array([Vector2(sx,sy),Vector2(ex,sy),Vector2(ex,ey), Vector2(sx,ey)]))
	frame.set_opacity(0.3)
	points = get_node("Points")
	set_pos(Vector2(0,0))

func update_rot():
	set_rot(-get_parent().get_rot())

func update():
	var ratio = float(get_parent().curr_hp)/get_parent().hitpoints
	var sx = -16
	var sy = -28
	var ex = sx + 32*ratio
	var ey = -34
	points.set_polygon(Vector2Array([Vector2(sx,sy),Vector2(ex,sy),Vector2(ex,ey), Vector2(sx,ey)]))
	if ratio < 0.2:
		points.set_color(Color(1,0,0))
	elif ratio < 0.6:
		points.set_color(Color(1,1,0))
	else:
		points.set_color(Color(0,1,0))

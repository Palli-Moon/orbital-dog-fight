
extends RigidBody2D

export var hitpoints = 100 setget set_hitpoints, get_hitpoints
var curr_hp

func _ready():
	curr_hp = hitpoints
	init_bar()
	set_fixed_process(true)
	pass


func _fixed_process(delta):
	pass

func set_hitpoints(hp):
	hitpoints = hp

func get_hitpoints():
	return hitpoints

func _die():
	queue_free()

func hit(beam):
	curr_hp -= beam.get_power()
	update_bar()
	if curr_hp <= 0:
		_die()

func init_bar():
	var sx = -17
	var sy = -27
	var ex = 17
	var ey = -35
	get_node("HealthBar/Frame").set_polygon(Vector2Array([Vector2(sx,sy),Vector2(ex,sy),Vector2(ex,ey), Vector2(sx,ey)]))
	get_node("HealthBar/Frame").set_opacity(0.3)
	update_bar()

func update_bar():
	var ratio = float(curr_hp)/hitpoints
	var sx = -16
	var sy = -28
	var ex = sx + 32*ratio
	var ey = -34
	get_node("HealthBar/Points").set_polygon(Vector2Array([Vector2(sx,sy),Vector2(ex,sy),Vector2(ex,ey), Vector2(sx,ey)]))
	if ratio < 0.2:
		get_node("HealthBar/Points").set_color(Color(1,0,0))
	elif ratio < 0.6:
		get_node("HealthBar/Points").set_color(Color(1,1,0))
	else:
		get_node("HealthBar/Points").set_color(Color(0,1,0))
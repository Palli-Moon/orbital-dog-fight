extends RigidBody2D

export(int, "ONE", "TWO") var player_num = 0
export var rot_speed = 16
export var fwd_speed = 10.0
export var bwd_speed = 5.0
export var strafe_speed = 3.0
var CONTROLS = ["fwd", "bwd", "sl", "sr", "tl", "tr"]
var impulse = null
var step = 0

func _ready():
	set_fixed_process(true)
	pass

func get_ctrl(type):
	return "p" + str(player_num+1) + "_" + type

func xform_dir(vec):
	return vec.rotated(get_transform().get_rotation())

func apply_ctrl(type, dt):
	if type == "fwd":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,-fwd_speed * dt)))
	elif type == "bwd":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,bwd_speed * dt)))
	elif type == "sl":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(-strafe_speed * dt,0)))
	elif type == "sr":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(strafe_speed * dt,0)))
	elif type == "tl":
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(-rot_speed * dt,0))
	elif type == "tr":
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(-rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(rot_speed * dt,0))
	else:
		print("Unkown command: " + type)

func get_particles(type):
	var nodes = []
	if type == "fwd":
		nodes = [get_node("RearThrusters")]
	elif type == "sl":
		nodes = [get_node("RearRightThruster"), get_node("FrontRightThruster")]
	elif type == "sr":
		nodes = [get_node("RearLeftThruster"), get_node("FrontLeftThruster")]
	elif type == "tl":
		nodes = [get_node("RearLeftThruster"), get_node("FrontRightThruster")]
	elif type == "tr":
		nodes = [get_node("RearRightThruster"), get_node("FrontLeftThruster")]
	return nodes
	
func show_particles(type):
	var nodes = get_particles(type)
	for node in nodes:
		node.show()

func hide_particles(type):
	var nodes = get_particles(type)
	for node in nodes:
		node.hide()

func _fixed_process(delta):
	var show = []
	for type in CONTROLS:
		if Input.is_action_pressed(get_ctrl(type)):
			show.append(type)
			apply_ctrl(type, delta)
		else:
			hide_particles(type)
	for type in show:
		show_particles(type)
	pass

#func _integrate_forces(state):
#	#print("Integrate! " + str(step))
#	#step+=1
#	if impulse != null:
#		print("OK!")
#		var pos = get_pos()
#		apply_impulse(pos, impulse)
#		state.integrate_forces()
#		apply_impulse(pos, -impulse)
#		impulse = null
#		#print("Gravity : ", state.get_total_gravity())
#		#print("Force   : ", get_applied_force())
#		#print("Velocity: ", get_linear_velocity())
#	else:
#		state.integrate_forces()


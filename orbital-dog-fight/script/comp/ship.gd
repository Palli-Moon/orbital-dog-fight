extends RigidBody2D

export(int, "ONE", "TWO") var player_num = 0
export var rot_speed = 50
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

func apply_ctrl(type):
	if type == "fwd":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,-1)))
	elif type == "bwd":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,1)))
	elif type == "sl":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(-1,0)))
	elif type == "sr":
		apply_impulse(Vector2(0,0), xform_dir(Vector2(1,0)))
	elif type == "tl":
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(1,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(-1,0))
	elif type == "tr":
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(-1,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(1,0))
	else:
		print("Unkown command: " + type)

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

func _fixed_process(delta):
	for type in CONTROLS:
		if Input.is_action_pressed(get_ctrl(type)):
			apply_ctrl(type)
	pass

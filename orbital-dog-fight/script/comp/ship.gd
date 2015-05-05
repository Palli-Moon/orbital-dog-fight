tool
extends RigidBody2D

export(int, "ONE", "TWO") var player_num = 0
export var hitpoints = 100 setget set_hitpoints, get_hitpoints
export var rot_speed = 16
export var fwd_speed = 10.0
export var bwd_speed = 5.0
export var strafe_speed = 3.0
export var laser_speed = 300.0
export(Texture) var shiptex setget set_shiptex, get_shiptex

const CMD_FORWARD = "fwd"
const CMD_BACKWARD = "bwd"
const CMD_STRAFE_LEFT = "sl"
const CMD_STRAFE_RIGHT = "sr"
const CMD_TURN_LEFT = "tl"
const CMD_TURN_RIGHT = "tr"
const CMD_FIRE_LASERS = "lasers"

var laser = preload("res://scene/comp/laser.xml")
var CONTROLS = [CMD_FORWARD, CMD_BACKWARD, CMD_STRAFE_LEFT, CMD_STRAFE_RIGHT,
				CMD_TURN_LEFT, CMD_TURN_RIGHT, CMD_FIRE_LASERS]
var healthBar = null
var step = 0
var fire_timer
var curr_hp

var isdying = false

func _init():
	if get_node("Sprite") != null:
		get_node("Sprite").set_texture(shiptex)

func _ready():
	curr_hp = hitpoints
	set_fixed_process(true)
	
	healthBar = get_node("HealthBar")
	healthBar.update()
	get_node("Sprite").set_texture(shiptex)
	fire_timer = get_node("FireTimer")
	pass

func get_ctrl(type):
	return "p" + str(player_num+1) + "_" + type

func get_shiptex():
	return get_node("Sprite").get_texture()

func set_shiptex(tex):
	if get_node("Sprite") != null:
		get_node("Sprite").set_texture(tex)

func set_hitpoints(hp):
	hitpoints = hp

func get_hitpoints(hp):
	return hitpoints

func xform_dir(vec):
	return vec.rotated(get_transform().get_rotation())

func apply_ctrl(type, dt):
	if type == CMD_FORWARD:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,-fwd_speed * dt)))
	elif type == CMD_BACKWARD:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,bwd_speed * dt)))
	elif type == CMD_STRAFE_LEFT:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(-strafe_speed * dt,0)))
	elif type == CMD_STRAFE_RIGHT:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(strafe_speed * dt,0)))
	elif type == CMD_TURN_LEFT:
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(-rot_speed * dt,0))
	elif type == CMD_TURN_RIGHT:
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(-rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(rot_speed * dt,0))
	elif type == CMD_FIRE_LASERS:
		fire()
	else:
		print("Unkown command: " + type)

func get_particles(type):
	var nodes = []
	if type == CMD_FORWARD:
		nodes = [get_node("RearThrusters")]
	elif type == CMD_STRAFE_LEFT:
		nodes = [get_node("RearRightThruster"), get_node("FrontRightThruster")]
	elif type == CMD_STRAFE_RIGHT:
		nodes = [get_node("RearLeftThruster"), get_node("FrontLeftThruster")]
	elif type == CMD_TURN_LEFT:
		nodes = [get_node("RearLeftThruster"), get_node("FrontRightThruster")]
	elif type == CMD_TURN_RIGHT:
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

	# Keeps the health bar on top
	healthBar.update_rot()

func fire():
	if fire_timer.get_time_left() != 0:
		return
	fire_timer.start()
	var scale = get_node("Sprite").get_scale()
	var la_l = laser.instance()
	var la_r = laser.instance()
	la_l.set_pos(Vector2(10 * scale.x,-34 * scale.y))
	la_r.set_pos(Vector2(-10 * scale.x,-34 * scale.y))
	la_l.set_linear_velocity(Vector2(0,-laser_speed).rotated(get_transform().get_rotation()))
	la_r.set_linear_velocity(Vector2(0,-laser_speed).rotated(get_transform().get_rotation()))
	add_child(la_l)
	add_child(la_r)

func _die():
	queue_free()

func hit(beam):
	curr_hp -= beam.get_power()
	if curr_hp <= 0:
		if !isdying:
			isdying = true
			get_node("explosion").show()
			get_node("explosion/AnimationPlayer").play("exp_one")
			get_node("Sprite").hide()
			healthBar.hide()
	else:
		healthBar.update()
	
func _on_AnimationPlayer_finished():
	_die()

func _on_AnimationPlayer_animation_changed( old_name, new_name ):
	# Disable collision
	set_layer_mask(0)
	get_node("Sprite").hide()

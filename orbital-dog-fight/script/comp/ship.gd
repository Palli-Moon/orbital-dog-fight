tool
extends RigidBody2D

export(int, "ONE", "TWO") var player_num = 0
export var hitpoints = 100
export var rot_speed = 16
export var fwd_speed = 10.0
export var bwd_speed = 5.0
export var strafe_speed = 3.0
export var laser_speed = 300.0
export(Texture) var shiptex setget set_shiptex, get_shiptex

var CMD = preload("res://script/comp/ship/commands.gd")
var laser = preload("res://scene/comp/laser.xml")
var end_screen = preload("res://scene/end_screen.xml")
var healthBar = null
var particles = null
var fire_timer = null
var curr_hp = 0

var isdying = false

func _ready():
	curr_hp = hitpoints
	if !get_tree().is_editor_hint():
		add_to_group("ships")
		add_to_group("shootables")
		set_fixed_process(true)
		# Manage child nodes
		fire_timer = get_node("FireTimer")
		healthBar = get_node("HealthBar")
		particles = get_node("Particles")
		healthBar.update()
		get_node("Sprite").set_texture(shiptex)
		# Bind animation events
		var anim = get_node("explosion/AnimationPlayer")
		anim.connect("finished", self, "anim_finished")
		anim.connect("animation_changed", self, "anim_changed")

func get_ctrl(type):
	return "p" + str(player_num+1) + "_" + type

func get_shiptex():
	if has_node("Sprite"):
		return get_node("Sprite").get_texture()
	return shiptex

func set_shiptex(tex):
	if has_node("Sprite"):
		get_node("Sprite").set_texture(tex)
	shiptex = tex

func xform_dir(vec):
	return vec.rotated(get_transform().get_rotation())

func apply_ctrl(type, dt):
	if type == CMD.FORWARD:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,-fwd_speed * dt)))
	elif type == CMD.BACKWARD:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(0,bwd_speed * dt)))
	elif type == CMD.STRAFE_LEFT:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(-strafe_speed * dt,0)))
	elif type == CMD.STRAFE_RIGHT:
		apply_impulse(Vector2(0,0), xform_dir(Vector2(strafe_speed * dt,0)))
	elif type == CMD.TURN_LEFT:
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(-rot_speed * dt,0))
	elif type == CMD.TURN_RIGHT:
		apply_impulse(Vector2(rot_speed,rot_speed), Vector2(-rot_speed * dt,0))
		apply_impulse(Vector2(-rot_speed,-rot_speed), Vector2(rot_speed * dt,0))
	elif type == CMD.FIRE_LASERS:
		fire()
	else:
		print("Unkown command: " + type)

func _fixed_process(delta):
	var show = []
	for type in CMD.ALL:
		if Input.is_action_pressed(get_ctrl(type)):
			show.append(type)
			apply_ctrl(type, delta)
		else:
			particles.hide_particles(type)
	for type in show:
		particles.show_particles(type)
	# Keeps the health bar on top
	healthBar.update_rot()
	# Check for collissions
	check_collisions()

func collide(b):
	curr_hp -= b.get_mass()
	if curr_hp <= 0:
		if !isdying:
			isdying = true
			get_node("explosion").show()
			get_node("explosion/AnimationPlayer").play("exp_one")
			healthBar.hide()
	else:
		healthBar.update()

func check_collisions():
	var bodies = get_colliding_bodies()
	for b in bodies:
		if b.is_in_group("ships") or b.is_in_group("asteroids"):
			collide(b)
		elif b.is_in_group("planet"):
			die("exp_one")

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
	var end = end_screen.instance()
	get_parent().add_child(end)
	queue_free()

func die(anim):
	if !isdying:
		isdying = true
		set_fixed_process(false)
		particles.hide()
		get_node("explosion").show()
		get_node("explosion/AnimationPlayer").play(anim)
		healthBar.hide()

func hit(beam):
	curr_hp -= beam.get_power()
	if curr_hp <= 0:
		die("exp_one")
	else:
		healthBar.update()
	
func anim_finished():
	get_node("explosion").hide()
	_die()

func anim_changed( old_name, new_name ):
	# Disable collision
	set_layer_mask(0)
	get_node("Sprite").hide()

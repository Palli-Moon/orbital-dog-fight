tool
#extends Node2D
extends "res://script/comp/orbital_obj.gd"

export var hitpoints = 100 setget set_hitpoints, get_hitpoints
export(Texture) var asteroid_texture setget set_asteroid_texture, get_asteroid_texture
export var scale = 1.0 setget set_scale, get_scale
export var can_shoot = false

var Asteroid

var curr_hp = 0
var health_bar = null
var heimdallr
var is_dying = false
var threshold = 0.3

var textures = [load("res://assets/img/asteroid1.png"), load("res://assets/img/asteroid2.png"), load("res://assets/img/asteroid3.png")]
var robotoroid = load("res://assets/img/robotoroid.png")

func on_ready():
	# Register events
	heimdallr = get_node("/root/Heimdallr")
	heimdallr.register_signal(self, "die")
	# Add to groups
	add_to_group("shootables")
	add_to_group("asteroids")
	add_to_group("sfx")
	if asteroid_texture != null:
		if can_shoot:
			get_node("Sprite").set_texture(robotoroid)
		else:
			get_node("Sprite").set_texture(asteroid_texture)
	if not get_tree().is_editor_hint():
		get_shape(0).set_radius(10*scale)
		get_node("Trigger").get_shape(0).set_radius(18*scale)
		health_bar = get_node("HealthBar")
		Asteroid = load("res://scene/comp/asteroid.xml")
	set_default_volume(get_node("/root/Demos/Settings").volume * int(!get_node("/root/Demos/Settings").muted))

func on_spawn():
	is_dying = false
	curr_hp = hitpoints
	health_bar.update()
	set_fixed_process(true)

func on_collide(body):
	pass

func on_separate(body):
	pass

func _fixed_process(delta):
	health_bar.update_rot()

func set_hitpoints(hp):
	hitpoints = hp

func get_hitpoints():
	return hitpoints

func set_default_volume(value):
	get_node("AsteroidSounds").set_default_volume(value)

func _die():
	if is_dying:
		return
	is_dying = true
	if scale > 1:
		var roids = floor(scale/randf())
		for i in range(roids):
			var littleroidscale = randf()
			if littleroidscale * scale > threshold:
				var littleroid = Asteroid.instance()
				var pos = get_pos()
				var vel = get_linear_velocity()
				littleroid.set_linear_velocity(vel)
				littleroid.apply_impulse(Vector2(0,0), Vector2((randf()-0.5)*50, (randf()-0.5)*50))
				littleroid.set_pos(pos+Vector2((randf()-0.5)*20, (randf()-0.5)*20))
				littleroid.hitpoints = hitpoints * littleroidscale
				littleroid.curr_hp = littleroid.hitpoints
				littleroid.scale = scale * littleroidscale
				var texnum = randi() % 3
				littleroid.set_asteroid_texture(textures[texnum])
				get_parent().add_child(littleroid)
				littleroid.spawn()
				scale = scale * (1-littleroidscale)
	heimdallr.send_signal(self, "die", [])
	remove_from_group("asteroids")
	explode()

func hit(beam):
	if is_dying:
		return
	get_node("AsteroidSounds").play("laser-hit2")
	curr_hp -= beam.get_power()
	health_bar.update()
	if curr_hp <= 0:
		_die()
		
func explode():
	get_node("Sprite").hide()
	get_node("HealthBar").hide()
	set_cd_enable(false)
	set_collision_enable(false)
	get_node("Node2D/explosion").show()
	get_node("Node2D/explosion/AnimationPlayer").play("Explode")

func set_asteroid_texture(tex):
	if has_node("Sprite"):
		get_node("Sprite").set_texture(tex)
	asteroid_texture = tex

func get_asteroid_texture():
	if has_node("Sprite"):
		return get_node("Sprite").get_texture()
	return asteroid_texture

func set_scale(scale):
	if has_node("Sprite"):
		get_node("Sprite").set_scale(Vector2(scale, scale))
	if has_node("CollisionShape2D"):
		get_node("CollisionShape2D").get_shape().set_radius(10*scale)
	if has_node("Trigger/CollisionShape2D"):
		get_node("Trigger/CollisionShape2D").get_shape().set_radius(18*scale)
	if has_node("Node2D/explosion"):
		get_node("Node2D/explosion").set_scale(Vector2(scale, scale))
	pass

func get_scale():
	return scale

func _on_AnimationPlayer_finished():
	queue_free()

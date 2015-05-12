tool
#extends Node2D
extends "res://script/comp/orbital_obj.gd"

export var hitpoints = 100 setget set_hitpoints, get_hitpoints
export(Texture) var asteroid_texture setget set_asteroid_texture, get_asteroid_texture
export var scale = 1.0 setget set_scale, get_scale

var asteroid = preload("res://scene/comp/asteroid.xml")

var curr_hp
var health_bar = null
var heimdallr
var is_dying = false

func on_ready():
	# Register events
	heimdallr = get_node("/root/Heimdallr")
	heimdallr.register_signal(self, "die")
	# Add to groups
	add_to_group("shootables")
	add_to_group("asteroids")
	add_to_group("sfx")
	if asteroid_texture != null:
		get_node("Sprite").set_texture(asteroid_texture)
	if not get_tree().is_editor_hint():
		get_shape(0).set_radius(10*scale)
		get_node("Trigger").get_shape(0).set_radius(18*scale)
	set_default_volume(get_node("/root/Demos/Settings").volume * int(!get_node("/root/Demos/Settings").muted))
	pass

func on_spawn():
	curr_hp = hitpoints
	health_bar = get_node("HealthBar")
	health_bar.update()
	set_fixed_process(true)
	pass

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
	if scale > 1 && !is_dying:
		is_dying = true
		var littleroid = asteroid.instance()
		var pos = get_pos()
		var vel = get_linear_velocity()
		littleroid.set_linear_velocity(vel)
		littleroid.apply_impulse(Vector2(0,0), Vector2(randf()*10, randf()*10))
		littleroid.set_pos(pos+Vector2((randf()-0.5)*10, (randf()-0.5)*10))
		littleroid.hitpoints = hitpoints * 0.5
		littleroid.curr_hp = littleroid.hitpoints
		littleroid.scale = scale * 0.5
		littleroid.set_asteroid_texture(load("res://assets/img/asteroid1.png"))
		get_parent().add_child(littleroid)
	heimdallr.send_signal(self, "die", [])
	queue_free()

func hit(beam):
	get_node("AsteroidSounds").play("laser-hit2")
	curr_hp -= beam.get_power()
	health_bar.update()
	if curr_hp <= 0:
		_die()

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
	pass

func get_scale():
	return scale
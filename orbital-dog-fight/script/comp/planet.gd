tool
extends Node2D

export var gravity = 150 setget set_gravity, get_gravity
export var gravity_size = 500 setget set_gravity_size, get_gravity_size
export var atmosphere = 0.4 setget set_atmosphere, get_atmosphere
export var atmosphere_size = 100 setget set_atmosphere_size, get_atmosphere_size
export var gravity_distance_scale = 0.0 setget set_g_scale, get_g_scale
export(Texture) var planet_texture setget set_planet_texture, get_planet_texture
export(Animation) var planet_animation setget set_planet_animation, get_planet_animation
export var planet_scale = 5.0 setget set_planet_scale, get_planet_scale

var heimdallr

func _ready():
	get_node("Explosion").hide()
	get_node("Body/Sprite").set_texture(planet_texture)
	if not get_tree().is_editor_hint():
		get_node("Gravity").get_shape(0).set_radius(gravity_size)
		get_node("Atmosphere").get_shape(0).set_radius(atmosphere_size)
	pass

func set_gravity(g):
	if has_node("Gravity"):
		get_node("Gravity").set_gravity(g)
	gravity = g

func get_gravity():
	return gravity

func set_gravity_size(size):
	if has_node("Gravity") and has_node("Gravity/CollisionShape2D"):
		get_node("Gravity/CollisionShape2D").get_shape().set_radius(size)
	gravity_size = size

func get_gravity_size():
	return gravity_size

func set_atmosphere(atm):
	if has_node("Atmosphere"):
		get_node("Atmosphere").set_linear_damp(atm)
	atmosphere = atm

func get_atmosphere():
	return atmosphere

func set_atmosphere_size(size):
	if has_node("Atmosphere") and has_node("Atmosphere/CollisionShape2D"):
		get_node("Atmosphere/CollisionShape2D").get_shape().set_radius(size)
	atmosphere_size = size

func get_atmosphere_size():
	return atmosphere_size

func set_g_scale(scale):
	if has_node("Gravity") and get_node("Gravity").has_method("set_gravity_distance_scale"):
		get_node("Gravity").set_gravity_distance_scale(scale)
	gravity_distance_scale = scale

func get_g_scale():
	return gravity_distance_scale
	
func set_planet_texture(tex):
	if has_node("Body/Sprite"):
		get_node("Body/Sprite").set_texture(tex)
	planet_texture = tex

func get_planet_texture():
	return planet_texture
	
func set_planet_scale(scale):
	if has_node("Body/Sprite"):
		get_node("Body/Sprite").set_scale(Vector2(scale, scale))
	if has_node("Body/CollisionShape2D"):
		get_node("Body/CollisionShape2D").get_shape().set_radius(16*scale)
	pass

func get_planet_scale():
	return planet_scale

func set_planet_animation(anim):
	if has_node("Body/Sprite/Animation"):
		var animation = get_node("Body/Sprite/Animation")
		animation.remove_animation("planet_rot")
		animation.add_animation("planet_rot", anim)
		planet_animation = anim

func get_planet_animation():
	return planet_animation

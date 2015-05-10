tool
extends Node2D

export var gravity = 150 setget set_gravity, get_gravity
export var gravity_size = 500 setget set_gravity_size, get_gravity_size
export var atmosphere = 0.4 setget set_atmosphere, get_atmosphere
export var atmosphere_size = 100 setget set_atmosphere_size, get_atmosphere_size
export var gravity_distance_scale = 0.0 setget set_g_scale, get_g_scale

func _ready():
	if not get_tree().is_editor_hint():
		get_node("Gravity").get_shape(0).set_radius(gravity_size)
		get_node("Atmosphere").get_shape(0).set_radius(atmosphere_size)
	pass

func set_gravity(g):
	if get_node("Gravity") != null:
		get_node("Gravity").set_gravity(g)
	gravity = g

func get_gravity():
	return gravity

func set_gravity_size(size):
	if get_node("Gravity") != null and get_node("Gravity/CollisionShape2D") != null:
		get_node("Gravity/CollisionShape2D").get_shape().set_radius(size)
	gravity_size = size

func get_gravity_size():
	return gravity_size

func set_atmosphere(atm):
	if get_node("Atmosphere") != null:
		get_node("Atmosphere").set_linear_damp(atm)
	atmosphere = atm

func get_atmosphere():
	return atmosphere

func set_atmosphere_size(size):
	if get_node("Atmosphere") != null and get_node("Atmosphere/CollisionShape2D") != null:
		get_node("Atmosphere/CollisionShape2D").get_shape().set_radius(size)
	atmosphere_size = size

func get_atmosphere_size():
	return atmosphere_size

func set_g_scale(scale):
	var node = get_node("Gravity")
	if node != null and node.has_method("set_gravity_distance_scale"):
		node.set_gravity_distance_scale(scale)
	gravity_distance_scale = scale

func get_g_scale():
	return gravity_distance_scale
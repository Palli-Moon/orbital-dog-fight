
extends RigidBody2D

export var hitpoints = 100 setget set_hitpoints, get_hitpoints
var curr_hp

func _ready():
	curr_hp = hitpoints
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
	if curr_hp <= 0:
		_die()

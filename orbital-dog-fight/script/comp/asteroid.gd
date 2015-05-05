
extends RigidBody2D

func _ready():
	set_fixed_process(true)
	pass


func _fixed_process(delta):
	pass

func _die():
	queue_free()

func hit(beam):
	_die()

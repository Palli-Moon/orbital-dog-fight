
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var moon = null
export var angular_delta = 0.0000001

func _ready():
	moon = get_node("Moon")
	set_fixed_process( true )
	# Initialization here
	pass

func _fixed_process(delta):
	set_rot(get_rot()+angular_delta*delta)
	moon.set_rot(-get_rot())


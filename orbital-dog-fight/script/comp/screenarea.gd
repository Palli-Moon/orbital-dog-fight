
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var active_timers = []
var bodies = []

export var timeout = 3.0 # timeout in seconds
func _ready():
	# Initialization here
	pass

func _on_ScreenExtents_body_enter( body ):
	print("----")
	if (body.is_in_group("ships")):
		print("ship")
	print("entered area")
	pass # replace with function body

func _on_ScreenExtents_body_exit( body ):
	print("----")
	print(body)
	if (body.is_in_group("ships")):
		print("ship")
	print("left area")
	pass # replace with function body


extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	pass

func show_end(text):
	get_node("End Text").set_text(text)
	show()
	get_tree().set_pause(true)
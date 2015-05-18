
extends Node2D

var visible = true
export var velocity = Vector2(0,0)
# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	get_node("Arrow").hide()
	get_node("Sprite").hide()
	get_node("Sprite").set_opacity(0.25)
	add_to_group("spawnpoints")
	# Initialization here
	pass


extends Node2D

var end_screen = preload("res://scene/end_screen.xml")

func _ready():
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	if ships.empty():
		spawn_end_screen("You lose!")
	elif asteroids.empty():
		spawn_end_screen("You win!")
		
func spawn_end_screen(message):
	var end = end_screen.instance()
	end.get_node("End Text").set_text(message)
	add_child(end)

extends Node2D

var end_screen = preload("res://scene/end_screen.xml")
var end

func _ready():
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_fixed_process(true)

func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	if ships.empty():
		end.show_end("You lose!")
	elif asteroids.empty():
		end.show_end("You win!")

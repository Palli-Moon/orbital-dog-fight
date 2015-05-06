
extends Node2D

var end_screen = preload("res://scene/end_screen.xml")
var end = null

func _ready():
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_fixed_process(true)

func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	if ships.size() == 1:
		end.show_end("Player " + str(ships[0].player_num + 1) + " wins!")

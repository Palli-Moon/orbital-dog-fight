
extends Node2D

var end_screen = preload("res://scene/end_screen.xml")

func _ready():
	set_fixed_process(true)
	pass
	
func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	if ships.size() == 1:
		spawn_end_screen("Player " + str(ships[0].player_num + 1) + " wins!")
		
func spawn_end_screen(message):
	var end = end_screen.instance()
	end.get_node("End Text").set_text(message)
	add_child(end)
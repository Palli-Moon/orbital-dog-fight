
extends Node2D

var end_screen = preload("res://scene/end_screen.xml")
var end = null

func _ready():
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_process(true)
	set_fixed_process(true)

func _process(delta):
	get_node("RespawnLabel/Time").set_text(str(round(get_node("Respawn").get_time_left())))

func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	if ships.size() == 1:
		end.show_end("Player " + str(ships[0].player_num + 1) + " wins!")

func _on_Respawn_timeout():
	print(get_tree().get_nodes_in_group("dead"))
	for b in get_tree().get_nodes_in_group("dead"):
		b.remove_from_group("dead")
		b.spawn_at(Vector2(360,360), Vector2(0,-120), 0)
	pass # replace with function body

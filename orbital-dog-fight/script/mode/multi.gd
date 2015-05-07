
extends Node2D

export var lives = 5

var finished = false
var end_screen = preload("res://scene/end_screen.xml")
var end = null

var state = {}

func _ready():
	get_node("/root/Heimdallr").set_game(self)
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_process(true)
	var ships = get_tree().get_nodes_in_group("ships")
	for s in ships:
		state[s.get_rid()] = lives

func _process(delta):
	if finished:
		get_tree().set_pause(true)
	get_node("RespawnLabel/Time").set_text(str(round(get_node("Respawn").get_time_left())))

func message(sender, sig, data):
	if sig == "die" and state.has(sender.get_rid()):
		state[sender.get_rid()]-=1
		if state[sender.get_rid()] < 1:
			finished = true
			var num = 0
			if sender.player_num == 0:
				num = 1
			end.show_end("Player " + str(num + 1) + " wins!")

func _on_Respawn_timeout():
	print(get_tree().get_nodes_in_group("dead"))
	for b in get_tree().get_nodes_in_group("dead"):
		b.remove_from_group("dead")
		b.spawn_at(Vector2(360,360), Vector2(0,-120), 0)

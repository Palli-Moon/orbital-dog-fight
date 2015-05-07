
extends "res://script/mode/mode.gd"

var end_screen = preload("res://scene/end_screen.xml")
var end

func _ready():
	state.ships = {}
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_fixed_process(true)
	# Init state
	var ships = get_tree().get_nodes_in_group("ships")
	for s in ships:
		set_mode_state_prop(s.get_rid(), s.dump_state())

func _fixed_process(delta):
	var ships = get_tree().get_nodes_in_group("ships")
	for s in ships:
		var old_state = get_mode_state_prop(s.get_rid())
		var new_state = s.dump_state()
		if old_state.dead == false and new_state.dead == true:
			print("dead")
		state.ships[s.get_rid()] = s.dump_state()
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	if ships.empty():
		end.show_end("You lose!")
	elif asteroids.empty():
		end.show_end("You win!")

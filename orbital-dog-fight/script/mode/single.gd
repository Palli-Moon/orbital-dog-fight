
extends "res://script/mode/mode.gd"

export var lives = 5

var end_screen = preload("res://scene/end_screen.xml")
var end

func _ready():
	state.ships = {}
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_fixed_process(true)
	# Init state
	state = {ship=get_node("Ship").dump_state()}

func _fixed_process(delta):
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	set_mode_state_prop("ship",get_node("Ship").dump_state())
	if state.ship.dead:
		end.show_end("You lose!")
	elif asteroids.empty():
		end.show_end("You win!")

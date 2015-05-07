extends Node2D

var state = {}

func _ready():
	pass

func get_mode_state():
	return state

func set_mode_state():
	return state

func get_mode_state_prop(prop):
	if state.has(prop):
		return state[prop]

func set_mode_state_prop(prop, val):
	state[prop] = val

func erase_mode_state_prop(prop, val):
	if state.has(prop):
		state.erase(prop)

func dump():
	for k in state.keys():
		print(k,"\t=\t",state[k])
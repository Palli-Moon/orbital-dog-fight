
extends Node2D

var CMD = preload("res://script/comp/ship/commands.gd")

func _ready():
	pass

func get_particles(type):
	var nodes = []
	if type == CMD.FORWARD:
		nodes = [get_node("RearThrusters")]
	elif type == CMD.TURN_LEFT:
		nodes = [get_node("RearLeftThruster"), get_node("FrontRightThruster")]
	elif type == CMD.TURN_RIGHT:
		nodes = [get_node("RearRightThruster"), get_node("FrontLeftThruster")]
	return nodes

func show_particles(type):
	var nodes = get_particles(type)
	for node in nodes:
		node.show()

func hide_particles(type):
	var nodes = get_particles(type)
	for node in nodes:
		node.hide()

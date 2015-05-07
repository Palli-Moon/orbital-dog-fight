
extends Node2D

var finish = false
var end_screen = preload("res://scene/end_screen.xml")
var end

func _ready():
	get_node("/root/Heimdallr").set_game(self)
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_process(true)

func _process(delta):
	if finish:
		get_tree().set_pause(true)

func message(sender, sig, data):
	print("Received ", sig, " from ", sender, " with data ", data)
	if sig == "die" and sender.is_in_group("ships"):
		finish = true
		end.show_end("You lose!")
	elif sig == "die" and sender.is_in_group("asteroids"):
		finish = true
		end.show_end("You win!")
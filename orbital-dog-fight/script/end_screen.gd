
extends Node2D

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		if get_node("/root/Demos") != null:
			var menu = get_node("/root/Demos")
			menu.simple_restart_scene()
			get_tree().set_pause(false)

func show_end(text):
	get_node("End Text").set_text(text)
	show()
	set_process_input(true)
	get_tree().set_pause(true)

extends Node2D

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		if get_parent().get_parent().has_method("next_scene") and get_parent().get_parent().has_method("is_win"):
			var scenenum = get_parent().get_parent().next_scene()
			if scenenum == 0 or !get_parent().get_parent().is_win():
				get_node("/root/Demos").load_scene("res://scene/mode/single.xml")
			else:
				get_node("/root/Demos").load_scene("res://scene/mode/single"+str(scenenum)+".xml")
			get_tree().set_pause(false)
			return
		if get_node("/root/Demos") != null:
			var menu = get_node("/root/Demos")
			menu.simple_restart_scene()
			get_tree().set_pause(false)

func show_end(text):
	get_node("End Text").set_text(text)
	if get_parent().get_parent().has_method("next_scene") and get_parent().get_parent().has_method("is_win"):
			var scenenum = get_parent().get_parent().next_scene()
			if scenenum == 0 or !get_parent().get_parent().is_win():
				print("lose or last level")
				get_node("Subtext/Press Enter").set_text("Press enter to restart")
			else:
				get_node("Subtext/Press Enter").set_text("Press enter for the next level")
	else:
		get_node("Subtext/Press Enter").set_text("Press enter to restart")
	show()
	set_process_input(true)
	get_tree().set_pause(true)
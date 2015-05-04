
extends Node2D

var menu_open = true
var pause = true
var current
var current_scene
var menu

func _ready():
	current = get_node("Current")
	menu = get_node("Main Menu")
	get_tree().set_pause(pause)
	set_process_input(true)
	pass

func _input(event):
	if event.is_action("main_menu") and event.is_pressed() and not event.is_echo() and current_scene != null:
		pause = menu_open
		toggle_pause()
		toggle_menu()

func clear_scene():
	var child = current.get_child(0)
	if child:
		child.queue_free()

func load_scene(scene):
	current_scene = scene
	var s = ResourceLoader.load(scene)
	current.add_child(s.instance())

func restart_scene():
	if current_scene == null:
		return
	toggle_menu()
	clear_scene()
	load_scene(current_scene)

func toggle_pause():
	pause = !pause
	get_tree().set_pause(pause)

func toggle_menu():
	menu_open = !menu_open
	if menu_open:
		get_node("Main Menu").show()
	else:
		get_node("Main Menu").hide()

# Button Handlers
func _on_Exit_pressed():
	OS.get_main_loop().quit()

func _on_Resume_pressed():
	if current_scene == null:
		return
	toggle_menu()
	toggle_pause()

func _on_Single_pressed():
	toggle_menu()
	clear_scene()
	load_scene("res://scene/mode/single.xml")
	toggle_pause()

func _on_Multi_pressed():
	toggle_menu()
	clear_scene()
	load_scene("res://scene/mode/multi.xml")
	toggle_pause()

func _on_Restart_pressed():
	restart_scene()
	toggle_pause()
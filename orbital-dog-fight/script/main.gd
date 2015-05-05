
extends Node2D

var menu_open = true
var pause = true
var current
var current_scene
var menu
export var alt_control_mode = false

func _ready():
	current = get_node("Current")
	menu = get_node("Main Menu")
	get_tree().set_pause(pause)
	set_input_map(false)
	set_process_input(true)
	pass

func set_input_map(mode):
	var actions = ["p1_tl", "p1_tr", "p1_sl", "p1_sr"]
	for v in actions:
		InputMap.erase_action(v)
		InputMap.add_action(v)
	var altactions = [actions[2], actions[3], actions[0], actions[1]]
	var remappableevents = [InputEvent(), InputEvent(), InputEvent(), InputEvent()]
	var keys = [KEY_Q, KEY_E, KEY_A, KEY_D]
	for event_num in range(remappableevents.size()):
		var curr_event = remappableevents[event_num]
		curr_event.type = InputEvent.KEY
		curr_event.scancode = keys[event_num]
		if !mode:
			InputMap.action_add_event(actions[event_num], curr_event)
		else:
			InputMap.action_add_event(altactions[event_num], curr_event)
	
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
	get_node("Main Menu/Resume").show()
	get_node("Main Menu/Restart").show()
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

func _on_CheckButton_toggled( pressed ):
	set_input_map(pressed)

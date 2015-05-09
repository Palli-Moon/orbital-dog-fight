
extends Node2D

var menu_open = true
var settings_open = false
var pause = true
var current
var current_scene
var settings
var musicPlayer
var menu
export var alt_control_mode = false

func _ready():
	current = get_node("Game/Viewport/Current")
	menu = get_node("Main Menu")
	settings = get_node("Settings")
	musicPlayer = get_node("MusicPlayer")
	get_tree().set_pause(pause)
	set_input_map(false, 1)
	set_input_map(false, 2)
	set_process_input(true)
	pass
	
func set_input_map(mode, pl):
	var actions = ["p"+str(pl)+"_tl", "p"+str(pl)+"_tr", "p"+str(pl)+"_sl", "p"+str(pl)+"_sr"]
	for v in actions:
		InputMap.erase_action(v)
		InputMap.add_action(v)
	var altactions = [actions[2], actions[3], actions[0], actions[1]]
	var remappableevents = [InputEvent(), InputEvent(), InputEvent(), InputEvent()]
	var keys
	if pl == 1:
		keys = [KEY_Q, KEY_E, KEY_A, KEY_D]
	if pl == 2:
		keys = [KEY_Y, KEY_I, KEY_H, KEY_K]
	for event_num in range(remappableevents.size()):
		var curr_event = remappableevents[event_num]
		curr_event.type = InputEvent.KEY
		curr_event.scancode = keys[event_num]
		if !mode:
			InputMap.action_add_event(actions[event_num], curr_event)
		else:
			InputMap.action_add_event(altactions[event_num], curr_event)
	
func _input(event):
	if event.is_action("main_menu") and event.is_pressed() and not event.is_echo():
		if settings_open:
			toggle_settings()
			toggle_menu()
		else:
			if current_scene != null:
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
		menu.show()
	else:
		menu.hide()

func toggle_settings():
	settings_open = !settings_open
	if settings_open:
		settings.show()
	else:
		settings.hide()

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

func _on_Settings_pressed():
	toggle_menu()
	toggle_settings()
	pass

func _on_Return_pressed():
	toggle_menu()
	toggle_settings()
	pass # replace with function body

func _on_P1_Controls_toggled( pressed ):
	set_input_map( pressed, 1)
	pass # replace with function body

func _on_P2_Controls_toggled( pressed ):
	set_input_map( pressed, 2)
	pass # replace with function body


func _on_MusicCheck_toggled( pressed ):
	if musicPlayer.isPlaying:
		musicPlayer.get_node("StreamPlayer").set_paused( !pressed )
		get_node("Settings/MusicSlider").set_ignore_mouse( true )
		musicPlayer.isFadingOut = false
		musicPlayer.isFadingIn = false
		musicPlayer.label.set_opacity(0)
		musicPlayer.hide()
	else:
		musicPlayer.get_node("StreamPlayer").set_paused( !pressed )
		get_node("Settings/MusicSlider").set_ignore_mouse( false )
		musicPlayer.label.set_opacity(1.0)
		musicPlayer.get_node("ShowTimer").start()
		musicPlayer.show()
	musicPlayer.isPlaying = !musicPlayer.isPlaying
	
	
	pass # replace with function body


func _on_MusicSlider_value_changed( value ):
	print(value)
	musicPlayer.get_node("StreamPlayer").set_volume( value )
	pass # replace with function body

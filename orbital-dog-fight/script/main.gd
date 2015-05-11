extends Node2D

var menu_open = true
var settings_open = false
var is_remapping = false
var pause = true
var current
var current_scene
var settings
var musicPlayer
var menu
export var alt_control_mode = false
var events = []
var CMD = preload("res://script/comp/ship/commands.gd")
var global_actions = []
var remapping = null

func _ready():
	current = get_node("Game/Viewport/Current")
	menu = get_node("Main Menu")
	settings = get_node("Settings")
	musicPlayer = get_node("MusicPlayer")
	get_tree().set_pause(pause)
	for command in CMD.ALL:
		global_actions.append("p1_"+str(command))
		global_actions.append("p2_"+str(command))
	set_process_input(true)
	pass

func remap(events):
	for action in global_actions:
		if InputMap.action_has_event(action, events[1]):
			is_remapping = false
			return
	for action in global_actions:
		if InputMap.action_has_event(action, events[0]):
			InputMap.erase_action(action)
			InputMap.add_action(action)
			InputMap.action_add_event(action, events[1])
	is_remapping = false
	remapping = null
	pass

func remap_action(event):
	if event.scancode != KEY_ESCAPE:
		var txt
		InputMap.erase_action(remapping)
		InputMap.add_action(remapping)
		InputMap.action_add_event(remapping, event)
		if event.scancode == KEY_TAB:
			txt = "tab"
		elif event.scancode == KEY_RETURN:
			txt = "\u21a9"
		elif event.scancode == KEY_SPACE:
			txt = "space"
		else:
			txt = str(event).split("Unicode: ")[1][0]
		get_node("Settings/P"+remapping[1]+"Controls/"+remapping).set_text(txt.to_upper())
	is_remapping = false
	remapping = null
			
func _input(event):
	if !is_remapping:
		if event.is_action("main_menu") and event.is_pressed() and not event.is_echo():
			if settings_open:
				toggle_settings()
				toggle_menu()
			else:
				if current_scene != null:
					pause = menu_open
					toggle_pause()
					toggle_menu()
	else:
		if event.type == InputEvent.KEY and event.is_pressed() and not event.is_echo():
			events.append(event)
			if remapping != null:
				remap_action(event)
			elif events.size() == 2:
				remap(events)
				events = []

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
	#print(value)
	musicPlayer.get_node("StreamPlayer").set_volume( value )
	pass # replace with function body

func _on_P1Remap_pressed():
	is_remapping = true
	pass # replace with function body

func _on_P1Forward_pressed():
	is_remapping = true
	remapping = "p1_fwd"
	pass # replace with function body

func _on_p1_back_pressed():
	is_remapping = true
	remapping = "p1_bwd"
	pass # replace with function body

func _on_p1_tl_pressed():
	is_remapping = true
	remapping = "p1_tl"
	pass # replace with function body

func _on_p1_tr_pressed():
	is_remapping = true
	remapping = "p1_tr"
	pass # replace with function body

func _on_p1_lasers_pressed():
	is_remapping = true
	remapping = "p1_lasers"
	pass # replace with function body

func _on_p2_fwd_pressed():
	is_remapping = true
	remapping = "p2_fwd"
	pass # replace with function body

func _on_p2_bwd_pressed():
	is_remapping = true
	remapping = "p2_bwd"
	pass # replace with function body

func _on_p2_tl_pressed():
	is_remapping = true
	remapping = "p2_tl"
	pass # replace with function body

func _on_p2_tr_pressed():
	is_remapping = true
	remapping = "p2_tr"
	pass # replace with function body

func _on_p2_lasers_pressed():
	is_remapping = true
	remapping = "p2_lasers"
	pass # replace with function body

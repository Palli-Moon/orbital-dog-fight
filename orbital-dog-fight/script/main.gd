extends Node2D

var menu_open = true
var settings_open = false
var multi_open = false
var is_remapping = false
var pause = true
var current
var current_scene
var settings
var musicPlayer
var menu
var splash
var remapping = null
var prefs

func _ready():
	splash = get_node("Splash")
	current = get_node("Game/Viewport/Current")
	menu = get_node("Main Menu")
	settings = get_node("Settings")
	musicPlayer = get_node("MusicPlayer")
	prefs = get_node("/root/Heimdallr").Settings
	get_tree().set_pause(pause)
	set_process_input(true)
	menu.hide()
	musicPlayer.hide()
	splash.get_node("Sprite/Animation").connect("finished",self,"splash_finished")
	pass
	
func _input(event):
	if !is_remapping:
		if event.is_action("main_menu") and event.is_pressed() and not event.is_echo():
			if settings_open:
				toggle_settings()
				toggle_menu()
			elif multi_open:
				toggle_multiplayer()
				toggle_menu()
			else:
				if current_scene != null:
					pause = menu_open
					toggle_pause()
					toggle_menu()
	else:
		if event.type == InputEvent.KEY and event.is_pressed() and not event.is_echo():
			if remapping != null:
				settings.remap_action(event)

func _clear_scene():
	get_node("/root/Heimdallr").game = null
	var child = current.get_child(0)
	if child:
		current.remove_child(child)
		child.queue_free()

func _load_sceme(scene):
	_clear_scene()
	get_node("Main Menu/Resume").show()
	get_node("Main Menu/Restart").show()
	current_scene = scene
	var s = ResourceLoader.load(scene)
	current.add_child(s.instance())

func _load_scene_instance(scene, name):
	_clear_scene()
	current_scene = name
	current.add_child(scene)

func load_scene(scene):
	call_deferred("_load_sceme", scene)

func load_scene_instance(scene, name):
	call_deferred("_load_scene_instance", scene, name)

func restart_scene():
	if current_scene == null:
		return
	toggle_menu()
	load_scene(current_scene)
	
func simple_restart_scene():
	if current_scene == null:
		return
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
	get_node("Settings/TutorialSwitch").set_pressed(!(prefs.get_value(prefs.SECTION_TUTORIAL, prefs.TUTORIAL_SEEN)))
	if is_remapping:
		is_remapping = false
		remapping = null
	settings_open = !settings_open
	if settings_open:
		settings.show()
	else:
		settings.hide()

func toggle_multiplayer():
	if multi_open:
		get_node("Multiplayer").hide()
	else:
		get_node("Multiplayer").show()
	multi_open = !multi_open

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
	load_scene("res://scene/mode/single.xml")
	toggle_pause()

func _on_Multi_pressed():
	toggle_menu()
	toggle_multiplayer()

func _on_Restart_pressed():
	restart_scene()
	toggle_pause()

func _on_Settings_pressed():
	toggle_menu()
	toggle_settings()
	pass

func splash_finished():
	splash.hide()
	menu.show()
	musicPlayer.show()

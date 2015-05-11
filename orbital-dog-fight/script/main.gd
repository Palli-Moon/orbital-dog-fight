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
var splash
var remapping = null

func _ready():
	splash = get_node("Splash")
	current = get_node("Game/Viewport/Current")
	menu = get_node("Main Menu")
	settings = get_node("Settings")
	musicPlayer = get_node("MusicPlayer")
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
			else:
				if current_scene != null:
					pause = menu_open
					toggle_pause()
					toggle_menu()
	else:
		if event.type == InputEvent.KEY and event.is_pressed() and not event.is_echo():
			if remapping != null:
				settings.remap_action(event)

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

func splash_finished():
	splash.hide()
	menu.show()
	musicPlayer.show()

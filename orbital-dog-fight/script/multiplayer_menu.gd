
extends Control

var main = null

func _ready():
	main = get_node("/root/Demos")
	get_node("Connect/Connect").connect("pressed", self, "on_client")
	get_node("Create/Create").connect("pressed", self, "on_server")
	get_node("Local").connect("pressed", self, "on_local")
	get_node("Back").connect("pressed", self, "on_back")

func load_scene(scene):
	main.clear_scene()
	main.current.add_child(scene)
	main.current_scene = "res://scene/mode/online.xml"
	main.get_node("Main Menu/Resume").show()
	main.get_node("Main Menu/Restart").hide()
	main.toggle_pause()

func on_client():
	var s = ResourceLoader.load("res://scene/mode/online.xml").instance()
	s.set_script(load("res://script/mode/client_mode.gd"))
	s.set_ip(get_node("Connect/Host").get_text())
	s.set_port(int(get_node("Connect/Port").get_text()))
	load_scene(s)
	main.toggle_multiplayer()

func on_server():
	var s = ResourceLoader.load("res://scene/mode/online.xml").instance()
	s.set_script(load("res://script/mode/server_mode.gd"))
	s.set_port(int(get_node("Create/Port").get_text()))
	load_scene(s)
	main.toggle_multiplayer()

func on_local():
	main.clear_scene()
	main.load_scene("res://scene/mode/multi.xml")
	main.toggle_multiplayer()
	main.toggle_pause()
	
func on_back():
	main.toggle_multiplayer()
	main.toggle_menu()
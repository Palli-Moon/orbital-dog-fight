
extends Node2D

func _ready():
	get_node("Control/Connect/Connect").connect("pressed", self, "on_client")
	get_node("Control/Create/Create").connect("pressed", self, "on_server")
	get_node("Control/Local").connect("pressed", self, "on_local")
	get_node("Control/Back").connect("pressed", self, "on_back")

func load_scene(scene):
	var mode = get_node("Mode")
	for c in mode.get_children():
		mode.remove_child(c)
	mode.add_child(scene)

func on_client():
	var s = ResourceLoader.load("res://scene/mode/online.xml").instance()
	s.set_script(load("res://script/mode/client_mode.gd"))
	load_scene(s)
	s.set_ip(get_node("Control/Connect/Host").get_text())
	s.set_port(get_node("Control/Connect/Port").get_text())
	get_node("Control").hide()

func on_server():
	var s = ResourceLoader.load("res://scene/mode/online.xml").instance()
	s.set_script(load("res://script/mode/server_mode.gd"))
	s.set_port(int(get_node("Control/Create/Port").get_text()))
	load_scene(s)
	get_node("Control").hide()

func on_local():
	var s = ResourceLoader.load("res://scene/mode/multi.xml").instance()
	load_scene(s)
	get_node("Control").hide()

extends Control

var Settings
var main = null

func _ready():
	Settings = get_node("/root/Heimdallr").Settings
	main = get_node("/root/Demos")
	get_node("Connect/Connect").connect("pressed", self, "on_client")
	get_node("Create/Create").connect("pressed", self, "on_server")
	get_node("Local").connect("pressed", self, "on_local")
	get_node("Back").connect("pressed", self, "on_back")
	# Load user settings
	get_node("Connect/Name").set_text(Settings.get_value(Settings.SECTION_NETWORK, Settings.NETWORK_PLAYER_NAME))
	get_node("Connect/Host").set_text(Settings.get_value(Settings.SECTION_NETWORK, Settings.NETWORK_CLIENT_HOST))
	get_node("Connect/Port").set_text(str(Settings.get_value(Settings.SECTION_NETWORK, Settings.NETWORK_CLIENT_PORT)))
	get_node("Create/Port").set_text(str(Settings.get_value(Settings.SECTION_NETWORK, Settings.NETWORK_SERVER_PORT)))

func load_scene(scene):
	main.load_scene_instance(scene, "res://scene/mode/online.xml")
	main.get_node("Main Menu/Resume").show()
	main.get_node("Main Menu/Restart").hide()
	main.toggle_pause()

func on_client():
	var s = ResourceLoader.load("res://scene/mode/online.xml").instance()
	s.set_script(load("res://script/mode/client_mode.gd"))
	s.set_ip(get_node("Connect/Host").get_text())
	s.set_port(int(get_node("Connect/Port").get_text()))
	s.player_name = get_node("Connect/Name").get_text()
	Settings.set_value(Settings.SECTION_NETWORK, Settings.NETWORK_PLAYER_NAME, s.player_name)
	Settings.set_value(Settings.SECTION_NETWORK, Settings.NETWORK_CLIENT_HOST, s.ip)
	Settings.set_value(Settings.SECTION_NETWORK, Settings.NETWORK_CLIENT_PORT, s.port)
	Settings.save()
	load_scene(s)
	main.toggle_multiplayer()

func on_server():
	var s = ResourceLoader.load("res://scene/mode/server_mode.xml").instance()
	s.get_node("Server").get_node("Server").set_port(int(get_node("Create/Port").get_text()))
	s.get_node("Client").set_port(int(get_node("Create/Port").get_text()))
	Settings.set_value(Settings.SECTION_NETWORK, Settings.NETWORK_SERVER_PORT, s.get_node("Client").port)
	Settings.save()
	load_scene(s)
	main.toggle_multiplayer()

func on_local():
	main.load_scene("res://scene/mode/multi.xml")
	main.toggle_multiplayer()
	main.toggle_pause()
	
func on_back():
	main.toggle_multiplayer()
	main.toggle_menu()
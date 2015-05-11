extends Node

var is_server = false
var is_dedicated = false
var client = null
var server = null
var debug = true

var Server = preload("res://script/net/server.gd")
var Client = preload("res://script/net/client.gd")

class OnlineClient extends "res://script/net/client.gd".ClientHandler:
	func on_connect(stream):
		pass
	
	func on_disconnect(stream):
		pass
	
	func on_message(stream, message):
		pass

class OnlineServer extends "res://script/net/server.gd".ServerHandler:
	func on_connect(client, stream):
		pass
	
	func on_disconnect(client, stream):
		pass
	
	func on_message(client, stream, message):
		pass

func _ready():
	if not is_server:
		if debug:
			server = get_node("Server")
			server.set_handler(OnlineServer.new())
			server.start()
		client = get_node("Client")
		client.set_handler(OnlineClient.new())
		client.connect()
	else:
		return
		server = OnlineServer.new()
		get_node("Server").set_script(OnlineServer)
		server.start()
	pass

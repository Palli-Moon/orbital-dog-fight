extends Node

var is_server = false
var is_dedicated = false
var client = null
var server = null
var debug = true

var players = {}
var Command = preload("res://script/net/commands.gd")
var Server = preload("res://script/net/server.gd")
var Client = preload("res://script/net/client.gd")
var Ship = preload("res://scene/comp/ship.xml")

class OnlineClient extends "res://script/net/client.gd".ClientHandler:
	var mode = null
	
	func _init(my_mode):
		mode = my_mode
	
	func on_connect(stream):
		mode.get_node("Client").send_data(mode.Command.ClientConnect.new("Pippo").get_msg())
		pass
	
	func on_disconnect(stream):
		pass
	
	func on_message(stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print("Unknown command " + str(message))
			return
		if msg.cmd == mode.Command.SERVER_CLIENT_ACCEPTED:
			mode.client_accepted(msg.id)

class OnlineServer extends "res://script/net/server.gd".ServerHandler:
	var inited = []
	var mode = null
	
	func _init(my_mode):
		mode = my_mode
	
	func on_connect(client, stream):
		pass
	
	func on_disconnect(client, stream):
		mode.player_left(client)
	
	func on_message(client, stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print("Unknown command " + str(message))
			return
		if msg.cmd == mode.Command.CLIENT_CONNECT:
			if inited.find(client) >= 0:
				print("Invalid command, client already connected")
				return
			mode.new_player(client, stream, msg.name)
			print("connected")

func _ready():
	seed(OS.get_unix_time())
	if not is_server:
		if debug:
			server = get_node("Server")
			server.set_handler(OnlineServer.new(self))
			server.start()
		client = get_node("Client")
		client.set_handler(OnlineClient.new(self))
		client.connect()
	else:
		server = get_node("Server")
		server.set_handler(OnlineServer.new(self))
		server.start()
	pass

func new_player(client, stream, name):
	var id = randi()
	var ship = create_ship()
	players[id] = {"client":client,"ship":ship}
	server.send_data(stream, Command.ServerClientAccepted.new(id).get_msg())
	server.broadcast(Command.ServerNewPlayer.new(id,name, ship).get_msg())

func player_left(client):
	for key in players.keys():
		if players[key] != null and players[key].client == client:
			print("Removing client")
			players[key].ship.queue_free()
			players.erase(key)
			break
	pass

func create_ship():
	var ship = Ship.instance()
	add_child(ship)
	return ship

func client_accepted(id):
	print("accepted: " + str(id))
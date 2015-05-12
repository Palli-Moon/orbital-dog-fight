extends Node

export var is_server = false
export var is_dedicated = false
var client = null
var server = null
var debug = true

var player_id = null
var player_name = "Unamed Player"
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
		mode.get_node("Client").send_data(mode.Command.ClientConnect.new(mode.player_name).get_msg())
		pass
	
	func on_disconnect(stream):
		pass
	
	func on_message(stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print_debug("Unknown command " + str(message))
		elif msg.cmd == mode.Command.SERVER_CLIENT_ACCEPTED:
			mode.client_accepted(msg.id)
		elif msg.cmd == mode.Command.SERVER_NEW_PLAYER:
			mode.client_new_player(msg.id, msg.name, msg.ship)

class OnlineServer extends "res://script/net/server.gd".ServerHandler:
	var mode = null
	
	func _init(my_mode):
		mode = my_mode
	
	func on_connect(client, stream):
		pass
	
	func on_disconnect(client, stream):
		mode.server_player_left(client)
	
	func on_message(client, stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print_debug("Unknown command " + str(message))
		elif msg.cmd == mode.Command.CLIENT_CONNECT:
			mode.server_player_join(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_UPDATE_CTRL:
			mode.server_client_update_ctrl(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_DISCONNECT:
			print_debug("client disconnected")

func _ready():
	seed(OS.get_unix_time())
	if not is_server:
		client = get_node("Client")
		client.set_handler(OnlineClient.new(self))
		client.connect()
	else:
		server = get_node("Server")
		server.set_handler(OnlineServer.new(self))
		server.start()

func server_player_join(client, stream, msg):
	var id = randi()
	var ship = create_ship()
	players[id] = {"client":client,"ship":ship,"name":msg.name}
	server.send_data(stream, Command.ServerClientAccepted.new(id).get_msg())
	server.broadcast(Command.ServerNewPlayer.new(id,msg.name, ship).get_msg())

func server_client_update_ctrl(client, stream, msg):
	print_debug("Not implemented yet")
	pass

func server_player_left(client):
	for key in players.keys():
		if players[key] != null and players[key].client == client:
			print_debug("Removing client")
			players[key].ship.queue_free()
			players.erase(key)
			break

func create_ship():
	var ship = Ship.instance()
	get_node("Game").add_child(ship)
	return ship

func client_accepted(id):
	player_id = id
	print_debug("accepted: " + str(id))

func client_new_player(id, name, ship):
	if id == player_id:
		return
	print_debug("New player")
	pass

func print_debug(mess):
	print(mess)
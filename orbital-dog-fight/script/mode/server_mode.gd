extends Node

export var is_dedicated = false

var server = null

var players = {}
var Command = preload("res://script/net/commands.gd")
var Server = preload("res://script/net/server.gd")
var Ship = preload("res://scene/comp/ship.xml")

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
			mode.player_join(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_UPDATE_CTRL:
			mode.player_update_ctrl(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_DISCONNECT:
			print_debug("client disconnected")

func _ready():
	seed(OS.get_unix_time())
	server = get_node("Server")
	server.set_handler(OnlineServer.new(self))
	server.start()

func player_join(client, stream, msg):
	var id = randi()
	var ship = create_ship()
	players[id] = {"client":client,"ship":ship,"name":msg.name}
	server.send_data(stream, Command.ServerClientAccepted.new(id).get_msg())
	server.broadcast(Command.ServerNewPlayer.new(id,msg.name, ship).get_msg())

func player_update_ctrl(client, stream, msg):
	print_debug("Not implemented yet")
	pass

func player_left(client):
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

func print_debug(mess):
	print(mess)
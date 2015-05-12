extends Node

var client = null

var player_id = null
var player_name = "Unamed Player"
var players = {}
var Command = preload("res://script/net/commands.gd")
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
func _ready():
	client = get_node("Client")
	client.set_handler(OnlineClient.new(self))
	client.connect()

func client_accepted(id):
	player_id = id
	print_debug("accepted: " + str(id))

func client_new_player(id, name, ship):
	if id == player_id:
		return
	print_debug("New player")

func create_ship():
	var ship = Ship.instance()
	get_node("Game").add_child(ship)
	return ship

func print_debug(mess):
	print(mess)
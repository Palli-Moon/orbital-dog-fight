extends Node

var client = null

var player_id = null
var player_name = "Unamed Player"
var ship = null
var curr_state = null
var State = preload("res://script/net/state.gd")
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
		mode.set_fixed_process(false)
		pass
	
	func on_message(stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print_debug("Unknown command from server: " + str(message))
		elif msg.cmd == mode.Command.SERVER_CLIENT_ACCEPTED:
			mode.accepted(msg.id)
		elif msg.cmd == mode.Command.SERVER_NEW_PLAYER:
			mode.new_player(msg.id, msg.name, msg.ship)
		elif msg.cmd == mode.Command.SERVER_STATE_UPDATE:
			mode.update_state(msg.state)

func _ready():
	curr_state = State.GameState.new()
	client = get_node("Client")
	client.set_handler(OnlineClient.new(self))
	client.connect()

func _fixed_process(delta):
	var updated = false
	for type in ship.CMD.ALL:
		var active = Input.is_action_pressed("p1_"+type)
		if ship.ctrl.has(type) and active != ship.ctrl[type]:
			updated = true
			ship.ctrl[type] = active
	if updated:
		client.send_data(Command.ClientUpdateCtrl.new(player_id, State.ControlState.new(ship.ctrl)).get_msg())
	pass

func accepted(id):
	player_id = id
	ship = Ship.instance()
	ship.is_remote = true
	ship.ctrl = State.ControlState.new(null).get_state()
	curr_state.add_player(id, player_name, ship, null)
	get_node("Game").add_child(ship)
	print_debug("accepted: " + str(id))
	set_fixed_process(true)

func new_player(id, name, ship):
	if id == player_id:
		return
	ship = Ship.instance()
	ship.is_remote = true
	ship.ctrl = State.ControlState.new(null).get_state()
	get_node("Game").add_child(ship)
	curr_state.add_player(id, name, ship, null)
	print_debug("New player")

func update_state(state):
	curr_state.update(state)

func create_ship():
	var ship = Ship.instance()
	get_node("Game").add_child(ship)
	return ship

func print_debug(mess):
	print(mess)
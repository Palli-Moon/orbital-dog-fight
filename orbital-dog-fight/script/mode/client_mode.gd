extends Node

export var ip = "127.0.0.1" setget set_ip, get_ip
export var port = 4666 setget set_port, get_port

func get_ip():
	return get_node("Client").ip

func set_ip(the_ip):
	get_node("Client").ip = the_ip
	ip = the_ip

func get_port():
	return get_node("Client").port

func set_port(the_port):
	get_node("Client").port = the_port
	port = the_port

var client = null

var player_id = null
var player_name = "Unamed Player"
var ship = null
var curr_state = null
var State = preload("res://script/net/state.gd")
var Command = preload("res://script/net/commands.gd")
var Client = preload("res://script/net/client.gd")
var Ship = preload("res://scene/comp/ship.xml")
var curr_ctrl = State.ControlState.new(null)

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
		elif msg.cmd == mode.Command.CLIENT_UPDATE_CTRL:
			mode.update_ctrl(msg.id, msg.ctrl)

func _ready():
	curr_state = State.GameState.new()
	client = get_node("Client")
	client.set_handler(OnlineClient.new(self))
	client.connect()

func _fixed_process(delta):
	var updated = false
	for type in ship.CMD.ALL:
		var active = Input.is_action_pressed("p1_"+type)
		if curr_ctrl.ctrl.has(type) and active != curr_ctrl.ctrl[type]:
			updated = true
			curr_ctrl.ctrl[type] = active
	if updated:
		client.send_data(Command.ClientUpdateCtrl.new(player_id, curr_ctrl.ctrl).get_msg())
	pass

func accepted(id):
	player_id = id
	ship = create_ship()
	curr_state.add_player(id, player_name, ship, null)
	print_debug("accepted: " + str(id))
	set_fixed_process(true)

func new_player(id, name, ship):
	if id == player_id:
		return
	var p_ship = create_ship()
	curr_state.add_player(id, name, p_ship, null)
	print_debug("New player")

func update_state(state):
	# Update current players and delete disconnected ones
	curr_state.update(state)
	# Add new players
	for k in state:
		if not curr_state.players.has(k):
			var p_ship = Ship.instance()
			p_ship.is_remote = true
			p_ship.ctrl = State.ControlState.new(null).get_state()
			get_node("Game").add_child(p_ship)
			curr_state.add_player(k, state[k].name, p_ship, null)
			curr_state.players[k].update_state(state[k])

func create_ship():
	var out = Ship.instance()
	out.is_remote = true
	out.ctrl = State.ControlState.new(null).get_state()
	out.set_linear_velocity(Vector2(150,0))
	out.set_pos(Vector2(400,200))
	get_node("Game").add_child(out)
	return out

func update_ctrl(id, ctrl):
	if id == player_id:
		curr_ctrl.ctrl = ctrl
		ship.ctrl = ctrl
	else:
		var p = curr_state.get_player_by_id(id)
		if p != null:
			p.ship.get_ship().ctrl = ctrl

func print_debug(mess):
	print(mess)
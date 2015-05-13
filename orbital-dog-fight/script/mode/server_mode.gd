extends Node

export var is_dedicated = false
export var port = 4666 setget set_port, get_port
export var max_conns = 4 setget set_max_conns, get_max_conns

func get_max_conns():
	return get_node("Server").max_conns

func set_max_conns(num):
	get_node("Server").max_conns = num
	max_conns = num

func get_port():
	return get_node("Server").port

func set_port(the_port):
	get_node("Server").port = the_port
	port = the_port

var server = null

var curr_state = null
var State = preload("res://script/net/state.gd")
var Command = preload("res://script/net/commands.gd")
var Server = preload("res://script/net/server.gd")
var Ship = preload("res://scene/comp/ship.xml")
var dt = 0

class OnlineServer extends "res://script/net/server.gd".ServerHandler:
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
			mode.print_debug("Unknown command from client: " + str(message))
		elif msg.cmd == mode.Command.CLIENT_CONNECT:
			mode.player_join(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_UPDATE_CTRL:
			mode.player_update_ctrl(client, stream, msg)
		elif msg.cmd == mode.Command.CLIENT_DISCONNECT:
			mode.print_debug("client disconnected")

func _ready():
	seed(OS.get_unix_time())
	curr_state = State.GameState.new()
	server = get_node("Server")
	server.set_handler(OnlineServer.new(self))
	server.start()
	set_fixed_process(true)

func _fixed_process(delta):
	dt += delta
	if dt >= 0.5:
		dt -= 0.5
		send_sync_state()

func send_sync_state():
	server.broadcast(Command.ServerStateUpdate.new(curr_state.get_state()).get_msg())

func player_join(client, stream, msg):
	var id = randi()
	var ship = create_ship()
	curr_state.add_player(id, msg.name, ship, client)
	server.send_data(stream, Command.ServerClientAccepted.new(id).get_msg())
	server.broadcast(Command.ServerNewPlayer.new(id,msg.name, ship).get_msg())

func player_update_ctrl(client, stream, msg):
	var p = curr_state.get_player_by_client(client)
	if p != null:
		p.ship.update_ctrl(msg.ctrl)
		server.broadcast(Command.ClientUpdateCtrl.new(p.id, msg.ctrl).get_msg())

func player_left(client):
	var p = curr_state.remove_player_by_client(client)
	if p != null:
		p.ship.get_ship().queue_free()

func create_ship():
	var ship = Ship.instance()
	ship.is_remote = true
	ship.ctrl = {fwd=false,bwd=false,tl=false,tr=false,lasers=false}
	ship.set_linear_velocity(Vector2(150,0))
	ship.set_pos(Vector2(800,200))
	get_node("Game").add_child(ship)
	return ship

func print_debug(mess):
	print(mess)
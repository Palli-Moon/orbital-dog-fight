extends Node

export var is_dedicated = false
export var port = 4666 setget set_port, get_port
export var max_conns = 4 setget set_max_conns, get_max_conns

const STATE_SYNC_DELAY = 0.1

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
var Heimdallr = null
var dt = 0
var is_end = false
var end_timeout = 10
var winning_score = 5

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
	if has_node("/root/Heimdallr"):
		Heimdallr = get_node("/root/Heimdallr")
		Heimdallr.set_game(self)
	curr_state = State.GameState.new()
	server = get_node("Server")
	server.set_handler(OnlineServer.new(self))
	server.start()
	get_node("UI/Timer").connect("timeout",self,"respawn")
	set_process(true)
	set_fixed_process(true)

func message(sender,sig,data):
	if sender.get_parent() != get_node("Game"):
		return
	if sig == "die":
		if data.size() > 0:
			if data[0] == null or data[0] == sender:
				curr_state.get_player_by_ship(sender).score -= 1
			else:
				var p = curr_state.get_player_by_ship(data[0])
				if p != null:
					p.score += 1
					if p.score >= winning_score:
						end_game(p.name)

func end_game(winner):
	get_node("UI/Timer").start()
	is_end = true
	server.broadcast(Command.ServerGameEnds.new(winner).get_msg())
	# Clean lasers
	var lasers = get_tree().get_nodes_in_group("lasers")
	for l in lasers:
		if lasers.get_parent() == get_node("Game"):
			lasers.queue_free()

func respawn():
	var all_spawns = get_tree().get_nodes_in_group("spawnpoints")
	var spawns = []
	for sp in all_spawns:
		if sp.get_parent() == get_node("Game"):
			spawns.append(sp)
	if is_end:
		is_end = false
		server.broadcast(Command.ServerGameRestart.new().get_msg())
		for k in curr_state.players:
			curr_state.players[k].score = 0
			var sp = get_spawnpoint(spawns)
			spawns.remove(spawns.find(sp))
			curr_state.players[k].get_ship().spawn_at(sp.get_pos(), sp.velocity, sp.get_rot())
			curr_state.players[k].get_ship().spawn_at(Vector2(800,300), Vector2(150,0), 0)
		return
	var ships = get_tree().get_nodes_in_group("dead")
	for s in ships:
		if s.get_parent() == get_node("Game"):
			var sp = get_spawnpoint(spawns)
			spawns.remove(spawns.find(sp))
			s.spawn_at(sp.get_pos(), sp.velocity, sp.get_rot())

func _process(delta):
	if is_end:
		return
	curr_state.time = str(round(get_node("UI/Timer").get_time_left()))
	get_node("UI/SpawnLabel/SpawnTime").set_text(curr_state.time)

func _fixed_process(delta):
	dt += delta
	if dt >= STATE_SYNC_DELAY and not is_end:
		dt -= STATE_SYNC_DELAY
		send_sync_state()

func send_sync_state():
	var lasers = get_tree().get_nodes_in_group("lasers")
	for l in lasers:
		if not curr_state.lasers.has(l.get_rid().get_id()) and l.get_parent() == get_node("Game"):
			curr_state.add_laser(l.get_rid().get_id(), l)
	var to_remove = []
	for k in curr_state.lasers:
		if not curr_state.lasers[k].is_valid():
			to_remove.append(k)
	for k in to_remove:
		curr_state.lasers.erase(k)
	server.broadcast(Command.ServerStateUpdate.new(curr_state.get_state()).get_msg())

func player_join(client, stream, msg):
	var id = randi()
	var ship = create_ship()
	curr_state.add_player(id, msg.name, ship, client)
	server.send_data(stream, Command.ServerClientAccepted.new(id, State.ShipState.new(ship)).get_msg())
	server.broadcast(Command.ServerNewPlayer.new(id,msg.name, ship).get_msg())

func player_update_ctrl(client, stream, msg):
	if is_end:
		return
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
	get_node("Game").add_child(ship)
	return ship

func get_spawnpoint(spawns):
	if spawns.size() > 0:
		var spawnpoint = randi() % spawns.size()
		spawnpoint = spawns[spawnpoint]
		return spawnpoint

func print_debug(mess):
	print(mess)
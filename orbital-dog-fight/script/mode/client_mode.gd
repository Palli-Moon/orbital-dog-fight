extends Node

export var ip = "127.0.0.1" setget set_ip, get_ip
export var port = 4666 setget set_port, get_port

const STATE_SYNC_DELAY = 0.1

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
var Laser = preload("res://scene/comp/laser.xml")
var curr_ctrl = State.ControlState.new(null)
var sync_delta = 0
var prediction = {}

class OnlineClient extends "res://script/net/client.gd".ClientHandler:
	var mode = null
	
	func _init(my_mode):
		mode = my_mode
	
	func on_connect(stream):
		mode.get_node("Client").send_data(mode.Command.ClientConnect.new(mode.player_name).get_msg())
		pass
	
	func on_disconnect(stream):
		mode.set_fixed_process(false)
		mode.set_process(false)
		pass
	
	func on_message(stream, message):
		var msg = mode.Command.parse(message)
		if msg == null:
			print_debug("Unknown command from server: " + str(message))
		elif msg.cmd == mode.Command.SERVER_CLIENT_ACCEPTED:
			mode.accepted(msg.id, msg.ship)
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

func _process(delta):
	sync_delta += delta
	var weight = sync_delta / STATE_SYNC_DELAY
	for k in curr_state.players:
		var p = curr_state.players[k].ship.get_ship()
		var from = p.get_pos()
		var to = prediction[k][0]
		p.set_pos(Vector2(lerp(from.x, to.x, weight), lerp(from.y, to.y, weight)))
		var from_r = p.get_rot()
		var to_r = prediction[k][1]
		var ang = prediction[k][2]
		if abs(from_r - to_r) < 0.15:
			p.set_rot(to_r)
		else:
			if ang > 0 and from_r < to_r:
				to_r -= 2*PI
			elif ang < 0 and from_r > to_r:
				to_r += 2*PI
			p.set_rot(lerp(from_r, to_r, weight))
		p.healthBar.update_rot()
		p.laserBar.update_rot()

func accepted(id, s):
	player_id = id
	ship = create_ship()
	ship.set_pos(s.pos)
	ship.set_rot(s.r)
	curr_state.add_player(id, player_name, ship, null)
	prediction[id] = get_prediction(s.pos, s.v, s.r, s.a)
	print_debug("accepted: " + str(id))
	set_fixed_process(true)
	set_process(true)

func new_player(id, name, ship):
	if id == player_id:
		return
	var p_ship = create_ship()
	curr_state.add_player(id, name, p_ship, null)
	print_debug("New player")

func update_state(state):
	sync_delta = 0
	get_node("UI/SpawnLabel/SpawnTime").set_text(str(state.t))
	var lasers = get_tree().get_nodes_in_group("lasers")
	var to_remove = []
	# Remove client simulated laser
	for l in lasers:
		if l.get_parent() == get_node("Game"):
			if l.remote_id == null:
				l.queue_free()
			elif not curr_state.lasers.has(l.remote_id):
				to_remove.append(l.remote_id)
				l.queue_free()
	for k in to_remove:
		curr_state.lasers.erase(k)
	# Update current players and lasers and delete disconnected ones
	curr_state.update(state)
	# Add new lasers
	for k in state.l:
		if not curr_state.lasers.has(k):
			var laser = create_laser(state.l[k].p, state.l[k].v, state.l[k].a, state.l[k].t, state.l[k].r)
			curr_state.add_laser(k, laser)
	# Add new players and populate prediction
	for k in state.p:
		if not curr_state.players.has(k):
			var p_ship = Ship.instance()
			p_ship.is_remote = true
			p_ship.ctrl = State.ControlState.new(null).get_state()
			get_node("Game").add_child(p_ship)
			curr_state.add_player(k, state.p[k].name, p_ship, null)
			curr_state.players[k].update_state(state.p[k])
		# Populate prediction of the next state
		prediction[k] = get_prediction(state.p[k].ship.pos, state.p[k].ship.v, state.p[k].ship.r, state.p[k].ship.a)

func get_prediction(pos, vel, rot, ang):
	var to_r = rot - ang * STATE_SYNC_DELAY
	if to_r > PI:
		to_r -= 2*PI
	elif to_r < -PI:
		to_r += 2*PI
	return [pos + vel * STATE_SYNC_DELAY, to_r, sign(ang)]

func create_ship():
	var out = Ship.instance()
	out.is_remote = true
	out.ctrl = State.ControlState.new(null).get_state()
	get_node("Game").add_child(out)
	out.is_dummy = true
	out.set_cd_enable(false)
	out.set_collision_enable(false)
	out.set_mode(Physics2DServer.BODY_MODE_STATIC)
	return out

func create_laser(pos, vel, ang, timer, rot):
	var out = Laser.instance()
	out.set_pos(pos)
	out.set_linear_velocity(vel)
	out.set_angular_velocity(ang)
	out.set_rot(rot)
	out.get_node("LifeTime").set_wait_time(timer)
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
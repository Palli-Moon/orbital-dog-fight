
const CLIENT_CONNECT = 0
const CLIENT_UPDATE_CTRL = 1
const CLIENT_DISCONNECT = 2
const SERVER_CLIENT_ACCEPTED = 100
const SERVER_STATE_UPDATE = 101
const SERVER_NEW_PLAYER = 102

class ClientConnect:
	var name
	const cmd = CLIENT_CONNECT
	
	func _init(my_name):
		name = my_name
	
	func get_msg():
		return [cmd, name]

class ClientUpdateCtrl:
	var id
	const cmd = CLIENT_UPDATE_CTRL
	var ctrl = {fwd=false,bwd=false,tl=false,tr=false,fire=false}
	
	func _init(my_id, fwd, bwd, tl, tr, fire):
		id = my_id
		ctrl.fwd = fwd
		ctrl.bwd = bwd
		ctrl.tl = tl
		ctrl.tr = tr
		ctrl.fire = fire
	
	func get_msg():
		return [cmd, id, ctrl.fwd, ctrl.bwd, ctrl.tl, ctrl.tr, ctrl.fire]

class ClientDisconnect:
	var id
	const cmd = CLIENT_DISCONNECT
	
	func _init(my_id):
		var id = my_id
	
	func get_msg():
		return [cmd, id]

class ServerClientAccepted:
	var id
	const cmd = SERVER_CLIENT_ACCEPTED
	
	func _init(my_id):
		id = my_id
	
	func get_msg():
		return [cmd, id]

class ServerStateUpdate:
	var state
	const cmd = SERVER_STATE_UPDATE
	
	func _init(s):
		state = s
	
	func get_msg():
		return [cmd, state]

class ServerNewPlayer:
	var id
	var ship
	var name
	const cmd = SERVER_NEW_PLAYER
	
	func _init(my_id, my_name, my_ship):
		id = my_id
		name = my_name
		ship = my_ship
	
	func get_msg():
		return [cmd, id, name, ship]

static func parse(data):
	if typeof(data) != TYPE_ARRAY || data.size() < 1 || typeof(data[0]) != TYPE_INT:
		print("Invalid data " + str(data))
		return null
	var cmd = data[0]
	if cmd == CLIENT_CONNECT:
		if data.size() != 2 || typeof(data[1]) != TYPE_STRING:
			return null
		return ClientConnect.new(data[1])
	elif cmd == CLIENT_DISCONNECT:
		if data.size() != 2 || typeof(data[1]) != TYPE_INT:
			return null
		return ClientDisconnect(data[1])
	elif cmd == CLIENT_UPDATE_CTRL:
		if data.size() != 7 || typeof(data[1]) != TYPE_INT || typeof(data[2]) != TYPE_BOOL || \
			typeof(data[3]) != TYPE_BOOL || typeof(data[4]) != TYPE_BOOL || typeof(data[5]) != TYPE_BOOL || \
			typeof(data[6]) != TYPE_BOOL:
			return null
		return ClientUpdateCtrl.new(data[1],data[2],data[3],data[4],data[5],data[6])
	elif cmd == SERVER_CLIENT_ACCEPTED:
		if data.size() != 2 || typeof(data[1]) != TYPE_INT:
			return null
		return ServerClientAccepted.new(data[1])
	elif cmd == SERVER_STATE_UPDATE:
		# TODO Check/parse state type?!
		if data.size() != 2 || typeof(data[1]) != TYPE_DICTIONARY:
			return null
		return ServerStateUpdate.new(data[1])
	elif cmd == SERVER_NEW_PLAYER:
		# TODO Check ship/parse type?!
		if data.size() != 4 || typeof(data[1]) != TYPE_INT || typeof(data[2]) != TYPE_STRING:
			return null
		return ServerNewPlayer.new(data[1], data[2], data[3])
	print("Unknown client command")
	return null
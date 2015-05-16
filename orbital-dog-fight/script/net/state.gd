
class ControlState:
	var ctrl = null
	
	func _init(state):
		if state != null:
			ctrl = state
		else:
			ctrl = {fwd=false,bwd=false,tl=false,tr=false,lasers=false}
	
	func get_state():
		return ctrl

class ShipState:
	var ship
	
	func _init(s):
		ship = s
	
	func get_ship():
		return ship
	
	func get_state():
		var my_ctrl
		if ship.ctrl != null:
			my_ctrl = ship.ctrl
		else:
			my_ctrl = {fwd=false,bwd=false,tl=false,tr=false,lasers=false}
		return {pos=ship.get_pos(),r=ship.get_rot(),v=ship.get_linear_velocity(),
			a=ship.get_angular_velocity(),hp=ship.curr_hp,l=ship.laser_heat,ctrl=my_ctrl}
	
	func update_state(s):
		#ship.set_linear_velocity(s.v)
		#ship.set_rot(s.r)
		#ship.set_pos(s.pos)
		#ship.set_angular_velocity(s.a)
		ship.curr_hp = s.hp
		ship.ctrl = s.ctrl
		ship.laser_heat = s.l
	
	func update_ctrl(ctrl):
		ship.ctrl = ctrl

class PlayerState:
	var id
	var name
	var ship
	var client
	
	func _init(my_id,my_name,my_ship,my_client):
		id = my_id
		name = my_name
		ship = ShipState.new(my_ship)
		client = my_client
	
	func get_state():
		return {"id":id,"name":name,"ship":ship.get_state()}
	
	func update_state(state):
		name = state.name
		ship.update_state(state.ship)

class LaserState:
	var id
	var laserRef
	
	func _init(my_id,my_laser):
		id = my_id
		laserRef = weakref(my_laser)
	
	func get_state():
		var laser = laserRef.get_ref()
		return {p=laser.get_pos(),r=laser.get_rot(),v=laser.get_linear_velocity(),
			a=laser.get_angular_velocity(),t=laser.get_node("LifeTime").get_wait_time(),r=laser.get_rot()}
	
	func update_state(s):
		var laser = laserRef.get_ref()
		laser.set_linear_velocity(s.l.v)
		laser.set_rot(s.l.r)
		laser.set_pos(s.l.pos)
		laser.set_angular_velocity(s.l.a)
		laser.set_rot(s.l.r)
		laser.get_node("LifeTime").set_wait_time(s.l.t)
	
	func is_valid():
		return laserRef.get_ref() != null

class GameState:
	var players = {}
	var lasers = {}
	var sync_interval = 0.1
	
	func add_player(id, name, ship, client):
		if players.has(id):
			print("Player already in state")
			return
		players[id] = PlayerState.new(id, name, ship, client)
	
	func add_laser(id, laser):
		if lasers.has(id):
			print("Laser already in state")
		laser.remote_id = id
		lasers[id] = LaserState.new(id, laser)
	
	func remove_player_by_client(client):
		for k in players.keys():
			if players[k] != null and players[k].client == client:
				var out = players[k]
				players.erase(k)
				return out
		return null
	
	func remove_player_by_id(id):
		var player = players[id]
		if player != null:
			players.erase(id)
			return player
		return null
	
	func get_player_by_id(id):
		if players.has(id):
			return players[id]
		return null
	
	func get_player_by_client(client):
		for k in players.keys():
			if players[k] != null and players[k].client == client:
				return players[k]
		return null
	
	func get_state():
		var out = {p={},l={},i=sync_interval}
		for k in players.keys():
			out.p[k] = players[k].get_state()
		for k in lasers.keys():
			out.l[k] = lasers[k].get_state()
		return out
	
	func update(state):
		var to_remove = []
		# Known players
		for k in players.keys():
			# Remove deleted players
			if not state.p.has(k):
				to_remove.append(k)
			# Update known players
			else:
				players[players[k].id].update_state(state.p[k])
		for k in to_remove:
			var p = players[k]
			players.erase(k)
			p.ship.get_ship().queue_free()

class ShipState:
	var ship
	
	func _init(s):
		ship = s
	
	func get_state():
		var my_ctrl = {}
		if ship.ctrl != null:
			my_ctrl = ship.ctrl
		else:
			my_ctrl = {fwd=false,bwd=false,tl=false,tr=false,lasers=false}
		return {pos=ship.get_pos(),v=ship.get_linear_velocity(),
			a=ship.get_angular_velocity(),hp=ship.curr_hp,ctrl=my_ctrl}
	
	func update_state(s):
		ship.set_linear_velocity(s.v)
		ship.set_pos(s.pos)
		ship.set_angular_velocity(s.a)
		ship.curr_hp = s.hp
		ship.ctrl = s.ctrl

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

class GameState:
	var players = {}
	
	func add_player(id, name, ship, client):
		if players.has(id):
			print("Player already in state")
			return
		players[id] = PlayerState.new(id, name, ship, client)
	
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
	
	func get_state():
		var out = {}
		for k in players.keys():
			out[players[k].id] = players[k].get_state()
		return out
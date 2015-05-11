
class GameState:
	var ships = []
	
	func add_ship(ship):
		ships.append(ship)
	
	func remove_ship(rid):
		for i in range(ships.size()):
			if ships[i].get_rid() == rid:
				ships.remove(i)
				break

class PlayerState:
	var ship
	var controls = {fwd=false,bwd=false,tl=false,tr=false,fire=false}
	
	func _init(my_ship):
		ship = my_ship

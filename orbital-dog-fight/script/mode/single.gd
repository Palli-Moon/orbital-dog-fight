
extends Node2D

var finish = false
var end_screen = preload("res://scene/end_screen.xml")
var end
var Settings = null

func _ready():
	Settings = get_node("/root/Heimdallr").Settings
	get_node("/root/Heimdallr").set_game(self)
	end = end_screen.instance()
	end.hide()
	get_node("EndContainer").add_child(end)
	#add_child(end)
	var ships = get_tree().get_nodes_in_group("ships")
	var spawns = get_tree().get_nodes_in_group("spawnpoints")
	for s in ships:
		var sp = get_spawnpoint(spawns)
		spawns.remove(spawns.find(sp))
		s.spawn_at(sp.get_pos(), sp.velocity, sp.get_rot())
	set_process(true)

func _process(delta):
	if finish:
		get_tree().set_pause(true)

func message(sender, sig, data):
	print("Received ", sig, " from ", sender, " with data ", data)
	if sig == "die" and sender.is_in_group("ships"):
		finish = true
		end.show_end("You lose!")
	elif sig == "die" and sender.is_in_group("asteroids") and get_tree().get_nodes_in_group("asteroids").size() == 1:
		finish = true
		end.show_end("You win!")
	elif sig == "crash":
		finish = true
		end.show_end("You lose!")

func get_spawnpoint(spawns):
		if spawns.size() > 0:
			var spawnpoint = randi() % spawns.size()
			spawnpoint = spawns[spawnpoint]
			return spawnpoint
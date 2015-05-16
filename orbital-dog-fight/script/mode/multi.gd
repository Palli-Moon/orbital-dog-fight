
extends Node2D

export var lives = 5

var life_scene = preload("res://scene/comp/life.xml")
var finished = false
var end_screen = preload("res://scene/end_screen.xml")
var end = null

var state = {}

func _ready():
	get_node("/root/Heimdallr").set_game(self)
	end = end_screen.instance()
	end.hide()
	add_child(end)
	set_process(true)
	var ships = get_tree().get_nodes_in_group("ships")
	var spawns = get_tree().get_nodes_in_group("spawnpoints")
	for s in ships:
		state[s.get_rid()] = lives
		update_lives(s)
		var sp = get_spawnpoint(spawns)
		spawns.remove(spawns.find(sp))
		s.spawn_at(sp.get_pos(), sp.velocity, sp.get_rot())

func update_lives(ship):
	var node = null
	var instance = null
	var spacing = 10
	var margin_l = 30
	var margin_r = 25
	var anchor_mode = Control.ANCHOR_BEGIN
	if ship.player_num == 0:
		node = get_node("Lives/P1")
	else:
		node = get_node("Lives/P2")
		anchor_mode = Control.ANCHOR_END
		spacing = 40
	for i in range(state[ship.get_rid()]):
		instance = life_scene.instance()
		instance.set_anchor_and_margin( MARGIN_RIGHT, anchor_mode, margin_r)
		instance.set_anchor_and_margin( MARGIN_LEFT, anchor_mode, margin_l * i + spacing)
		instance.set_margin( MARGIN_TOP, 10)
		node.add_child(instance)
	pass

func clear_lives(player_num):
	var node
	var lives_node = get_node("Lives/P"+str(player_num+1))
	for i in range(lives_node.get_child_count()):
		node = lives_node.get_child(i)
		node.queue_free()

func _process(delta):
	if finished:
		get_tree().set_pause(true)
	get_node("RespawnLabel/Time").set_text(str(round(get_node("Respawn").get_time_left())))

func message(sender, sig, data):
	if sig == "die" and state.has(sender.get_rid()):
		state[sender.get_rid()]-=1
		clear_lives(sender.player_num)
		update_lives(sender)
		if state[sender.get_rid()] < 1:
			finished = true
			var num = 0
			if sender.player_num == 0:
				num = 1
			end.show_end("Player " + str(num + 1) + " wins!")
			
func get_spawnpoint(spawns):
		if spawns.size() > 0:
			var spawnpoint = randi() % spawns.size()
			spawnpoint = spawns[spawnpoint]
			return spawnpoint
	
func _on_Respawn_timeout():
	print(get_tree().get_nodes_in_group("dead"))
	var spawns = get_tree().get_nodes_in_group("spawnpoints")
	for b in get_tree().get_nodes_in_group("dead"):
		b.remove_from_group("dead")
		var spawnpoint = get_spawnpoint(spawns)
		spawns.remove(spawns.find(spawnpoint))
		b.spawn_at(spawnpoint.get_pos(), spawnpoint.velocity, spawnpoint.get_rot())

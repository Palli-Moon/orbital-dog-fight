
extends Node2D

var finish = false
var end_screen = preload("res://scene/end_screen.xml")
var end
var screen_text
var t = 0
var Settings = null
var tutorial_seen

func _ready():
	Settings = get_node("/root/Heimdallr").Settings
	tutorial_seen = Settings.get_value(Settings.SECTION_TUTORIAL, Settings.TUTORIAL_SEEN)
	get_node("/root/Heimdallr").set_game(self)
	end = end_screen.instance()
	end.hide()
	add_child(end)
	screen_text = get_node("Screentext")
	if tutorial_seen:
		screen_text.hide()
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
	if !tutorial_seen:
		tutorial(delta)

func tutorial(delta):
	t += delta
	
	screen_text.hide()
	if t < 3:
		set_screen_text("Welcome to Orbital Dog-fight!", "Go forward with W\nTurn with Q and E")
	elif t < 6:
		set_screen_text("Welcome to Orbital Dog-fight!", "Press SPACE or X to shoot")
	elif t < 9:
		set_screen_text("Shoot the asteroid before", "it destroys your planet!")
	else:
		Settings.set_value(Settings.SECTION_TUTORIAL, Settings.TUTORIAL_SEEN, true)
		Settings.save()
		tutorial_seen = true

func set_screen_text(line1, line2):
	screen_text.show()
	screen_text.get_node("line1").set_text(line1)
	screen_text.get_node("line2").set_text(line2)

func message(sender, sig, data):
	print("Received ", sig, " from ", sender, " with data ", data)
	if sig == "die" and sender.is_in_group("ships"):
		finish = true
		end.show_end("You lose!")
	elif sig == "die" and sender.is_in_group("asteroids") and get_tree().get_nodes_in_group("asteroids").size() == 1:
		finish = true
		end.show_end("You win!")

func get_spawnpoint(spawns):
		if spawns.size() > 0:
			var spawnpoint = randi() % spawns.size()
			spawnpoint = spawns[spawnpoint]
			return spawnpoint
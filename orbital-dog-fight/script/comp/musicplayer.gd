
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var songnames = ["Tsrups - 505 - Relix", "Kitchentable - 505 - Relix"]
var songs = []
var currsong = 0

var playernode
var label

func _ready():
	# Initialization here
	playernode = get_child(0)
	label = get_child(1)
	for name in songnames:
		songs.append(load("res://sound/"+name+".ogg"))
		
	playernode.set_stream(songs[currsong])
	playernode.play()
	label.set_text(songnames[currsong])
	set_process(true)
	pass

func _process(delta):
	if !playernode.is_playing():
		currsong = (currsong + 1) % songs.size()
		playernode.set_stream(songs[currsong])
		label.set_text(songnames[currsong])
		playernode.play()



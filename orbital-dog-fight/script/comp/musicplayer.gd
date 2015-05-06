
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var songnames = ["Tsrups - 505 - Relix",
				 "Kitchentable - 505 - Relix",
				]
var songs = []
var currsong = 0
var playernode
var label
var showTimer
var fadeTimer
var isFadingOut = false
var isFadingIn = false

func _ready():
	# Initialization here
	playernode = get_child(0)
	label = get_child(1)
	showTimer = get_child(2)
	fadeTimer = get_child(3)
	for name in songnames:
		songs.append(load("res://sound/"+name+".ogg"))
	currsong = 0
	label.set_opacity(0)
	print(currsong)
	playernode.set_stream(songs[currsong])
	playernode.play()
	label.set_text(songnames[currsong])
	isFadingIn = true
	fadeTimer.start()
	set_process(true)
	pass

func _process(delta):
	if !playernode.is_playing():
		currsong = (currsong + 1) % songs.size()
		playernode.set_stream(songs[currsong])
		label.set_text(songnames[currsong])
		playernode.play()
		fadeTimer.start()
		isFadingIn = true
	if isFadingOut:
		label.set_opacity(fadeTimer.get_time_left()/fadeTimer.get_wait_time())
	elif isFadingIn:
		label.set_opacity(1- (fadeTimer.get_time_left()/fadeTimer.get_wait_time()))

func _on_Timer_timeout():
	showTimer.stop()
	print("showtimer")
	isFadingOut = true
	fadeTimer.start()
	
func _on_FadeTimer_timeout():
	fadeTimer.stop()
	print("fadetimer")
	if isFadingIn:
		showTimer.start()
	isFadingIn = false
	isFadingOut = false
	

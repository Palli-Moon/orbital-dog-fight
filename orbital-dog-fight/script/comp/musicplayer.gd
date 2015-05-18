
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var songnames = ["Tsrups - 505 - Relix",
				 "Kitchentable - 505 - Relix",
				 "Ground - 505 - Relix"
				]
var songs = []
var metadata = []
var currsong = 0
var playernode
var label
var showTimer
var fadeTimer
var muteButton
var isFadingOut = false
var isFadingIn = false
var muted = false
var isPlaying = true

func _ready():
	# Initialize random seed
	seed(OS.get_unix_time())
	# Initialization here
	playernode = get_child(0)
	label = get_child(1)
	showTimer = get_child(2)
	fadeTimer = get_child(3)
	muteButton = get_child(6)
	muteButton.set_focus_mode(Control.FOCUS_NONE)
	get_node("Forward").set_focus_mode(Control.FOCUS_NONE)
	get_node("Back").set_focus_mode(Control.FOCUS_NONE)
	for name in songnames:
		songs.append(load("res://sound/"+name+".ogg"))
	currsong = randi() % songnames.size()
	label.set_opacity(0)
	#print(currsong)
	playernode.set_stream(songs[currsong])
	playernode.play()
	label.set_text(songnames[currsong])
	isFadingIn = true
	fadeTimer.start()
	set_process(true)
	pass

func next_song():
	currsong = (currsong + 1) % songs.size()
	playernode.set_stream(songs[currsong])
	label.set_text(songnames[currsong])
	playernode.play()
	fadeTimer.start()
	showTimer.stop()
	isFadingIn = true
	if isFadingOut:
		isFadingOut = false

func prev_song():
	currsong = (currsong - 1 + songs.size()) % songs.size()
	playernode.set_stream(songs[currsong])
	label.set_text(songnames[currsong])
	playernode.play()
	fadeTimer.start()
	showTimer.stop()
	isFadingIn = true
	if isFadingOut:
		isFadingOut = false

func _process(delta):
	print(isPlaying)
	if isPlaying:
		if !playernode.is_playing():
			next_song()
	if isFadingOut:
		label.set_opacity(fadeTimer.get_time_left()/fadeTimer.get_wait_time())
	elif isFadingIn:
		label.set_opacity(1- (fadeTimer.get_time_left()/fadeTimer.get_wait_time()))

func _on_Timer_timeout():
	showTimer.stop()
	isFadingOut = true
	fadeTimer.start()
	
func _on_FadeTimer_timeout():
	fadeTimer.stop()
	if isFadingIn:
		showTimer.start()
	isFadingIn = false
	isFadingOut = false

func _on_Forward_pressed():
	next_song()
	pass # replace with function body


func _on_Back_pressed():
	prev_song()
	pass # replace with function body

func _on_Mute_pressed():
	if muted:
		playernode.set_volume(1)
		muteButton.set_text("Mute")
	else:
		playernode.set_volume(0)
		muteButton.set_text("Loud")
	muted = !muted
	
	pass # replace with function body

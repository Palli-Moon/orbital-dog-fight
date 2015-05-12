
extends Node

const SOUNDLEN = 44100

var server = AudioServer
var r = server.sample_create(0,false,SOUNDLEN)
var v = server.voice_create()
var snd = RawArray()

func _ready():
	for i in range(SOUNDLEN):
		snd.push_back(randi() % 30 + 1) 

	server.voice_set_volume(r, 0.1) # DOESN'T FUCKING WORK

	server.sample_set_data(r,snd)
	server.sample_set_loop_format(r, 1)
	server.sample_set_loop_begin(r, 0)
	server.sample_set_loop_end(r, SOUNDLEN)
	
func play_sound():
	server.voice_play(v,r)
	
func stop_sound():
	server.voice_stop(v)
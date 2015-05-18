
extends Node

const SOUNDLEN = 44100

var Settings
var server = AudioServer
var r = server.sample_create(0,false,SOUNDLEN)
var v = server.voice_create()
var snd = RawArray()

func _ready():
	Settings = get_node("/root/Heimdallr").Settings
	for i in range(SOUNDLEN):
		snd.push_back(randi() % 15 + 1) 
	server.sample_set_data(r,snd)
	server.sample_set_loop_format(r, 1)
	server.sample_set_loop_begin(r, 0)
	server.sample_set_loop_end(r, SOUNDLEN)
	
func play_sound():
	if not Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_FX_ENABLE):
		return
	server.voice_play(v,r)
	server.voice_set_volume(v, Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_FX_VOL))
	
func stop_sound():
	server.voice_stop(v)

func _exit_tree():
	# For compatibility with non bugfixed engines, we just leak in that case
	# See pull request
	# https://github.com/okamstudio/godot/pull/1931
	if server.has_method("free_rid"):
		server.free_rid(v)
		server.free_rid(r)
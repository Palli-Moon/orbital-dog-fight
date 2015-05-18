extends Node

var game

func _ready():
	# Seed the random number generator
	seed(OS.get_unix_time())
	# Loading Settings
	Settings = SettingsClass.new()
	if Settings.load(SettingsClass.PATH) != 0:
		print("Creating config file")
		Settings.load_defaults()
		if Settings.save() != 0:
			print("Unable to save config file, user settings will not be saved")
	Settings.load(SettingsClass.PATH)

func set_game(m):
	game = weakref(m)

func send_signal(sender, sig, args):
	if not sender.has_user_signal(sig):
		print("Signal ", sig ," not registered yet!")
		return
	if not sender.is_connected( sig, self, "message" ):
		print("Signal ", sig ," not connected yet!")
		return
	print("Sending: ", sig)
	sender.emit_signal(sig, sender, sig, args)

func register_signal(node, sig):
	if node.has_user_signal(sig):
		print("Signal already registered")
		return
	node.add_user_signal(sig, [{name="sender",type=TYPE_MAX},
		{name="signal",type=TYPE_STRING},
		{name="data", type=TYPE_DICTIONARY}])
	node.connect(sig, self, "message")

func message(sender, sig, data):
	print("Received ", str(sig), " from ", str(sender), " with data: ", str(data))
	if game == null or game.get_ref() == null:
		print("game not set, signal not sent!")
		return
	if not game.get_ref().has_method("message"):
		print("game is not compatible with Heimdallr (missing message(sender,sig,data) function)!")
		return
	game.get_ref().message(sender, sig, data)

func get_pref(key):
	pass

func set_pref(key, value):
	pass

#
# Settings related stuff
#
# Use get_node("/root/Heimdallr").Settings to access this, see ConfigFile as reference
# NOTE: save() function is overridden and takes no paramter. Remember to call it!
# NOTE: load(name) should NEVER be called.
#
# Examples:
# var Settings = get_node("/root/global").Settings
# var music_volume = Settings.get_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_VOL)
# Settings.set_value(Settings.SECTION_SOUND, Settings.SOUND_MUSIC_VOL, 50)
var Settings

class SettingsClass extends ConfigFile:
	const PATH = "user://settings.cfg"

	# Add more section if you like
	const SECTION_BINDING = "binding"
	const SECTION_SOUND = "sound"
	const SECTION_NETWORK = "network"
	const SECTION_TUTORIAL = "tutorial"

	#
	# Remember to use constants for names so we don't get lost!
	#

	# Sound Section
	const SOUND_MUSIC_ENABLE = "music_enabled"
	const SOUND_MUSIC_VOL = "music_volume"
	const SOUND_FX_ENABLE = "sfx_enabled"
	const SOUND_FX_VOL = "sfx_volume"

	# Network Section
	const NETWORK_PLAYER_NAME = "player_name"
	const NETWORK_CLIENT_HOST = "client_host"
	const NETWORK_CLIENT_PORT = "client_port"
	const NETWORK_SERVER_PORT = "server_port"
	
	# Bindings Section
	const BINDING_P1_FWD = "p1_fwd"
	const BINDING_P1_BWD = "p1_bwd"
	const BINDING_P1_TL = "p1_tl"
	const BINDING_P1_TR = "p1_tr"
	const BINDING_P1_LASERS = "p1_lasers"
	const BINDING_P2_FWD = "p2_fwd"
	const BINDING_P2_BWD = "p2_bwd"
	const BINDING_P2_TL = "p2_tl"
	const BINDING_P2_TR = "p2_tr"
	const BINDING_P2_LASERS = "p2_lasers"
	
	# Tutorial Section
	const TUTORIAL_SEEN = "tutorial_seen"

	func save():
		return .save(PATH)
	
	func _set_default(sec, name, value):
		if get_value(sec, name) == null:
			set_value(sec, name, value)

	func load_defaults():
		# Set defaults for Sound section
		_set_default(SECTION_SOUND, SOUND_FX_VOL, 1)
		_set_default(SECTION_SOUND, SOUND_FX_ENABLE, true)
		_set_default(SECTION_SOUND, SOUND_MUSIC_VOL, 1)
		_set_default(SECTION_SOUND, SOUND_MUSIC_ENABLE, true)
		# Set defaults for network section
		_set_default(SECTION_NETWORK, NETWORK_PLAYER_NAME, "Unamed Player")
		_set_default(SECTION_NETWORK, NETWORK_CLIENT_HOST, "127.0.0.1")
		_set_default(SECTION_NETWORK, NETWORK_CLIENT_PORT, 4666)
		_set_default(SECTION_NETWORK, NETWORK_SERVER_PORT, 4666)
		
		print(get_value(SECTION_BINDING, BINDING_P1_FWD))
		
		_set_default(SECTION_BINDING, BINDING_P1_FWD, ["W", KEY_W])
		_set_default(SECTION_BINDING, BINDING_P1_BWD, ["S", KEY_S])
		_set_default(SECTION_BINDING, BINDING_P1_TL, ["Q", KEY_Q])
		_set_default(SECTION_BINDING, BINDING_P1_TR, ["E", KEY_E])
		_set_default(SECTION_BINDING, BINDING_P1_LASERS, ["X", KEY_X, "SPACE", KEY_SPACE])
		_set_default(SECTION_BINDING, BINDING_P2_FWD, ["U", KEY_U])
		_set_default(SECTION_BINDING, BINDING_P2_BWD, ["J", KEY_J])
		_set_default(SECTION_BINDING, BINDING_P2_TL, ["Y", KEY_Y])
		_set_default(SECTION_BINDING, BINDING_P2_TR, ["I", KEY_I])
		_set_default(SECTION_BINDING, BINDING_P2_LASERS, ["M", KEY_M])
		
		_set_default(SECTION_TUTORIAL, TUTORIAL_SEEN, false)
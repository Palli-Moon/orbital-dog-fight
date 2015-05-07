extends Node2D

var game

func _ready():
	pass

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
	if game.get_ref() == null:
		print("game not set, signal not sent!")
		return
	if not game.get_ref().has_method("message"):
		print("game is not compatible with Heimdallr (missing message(sender,sig,data) function)!")
		return
	game.get_ref().message(sender, sig, data)

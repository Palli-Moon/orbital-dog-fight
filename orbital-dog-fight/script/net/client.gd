extends Node

export var port = 4666
export var ip = "127.0.0.1"

var debug
var handler = null

var Command = preload("commands.gd")
var conn
var stream
var is_conn = false

# Extend this class to create a server handler
class ClientHandler:
	func on_connect(stream):
		print_debug("You should extend on_connect(client, stream)")
	
	func on_disconnect(stream):
		print_debug("You should override on_disconnect(client, stream)")
	
	func on_message(stream, message):
		print_debug("You should override on_message(client, stream, message)")
	
	func print_debug(mess):
		print(mess)

func _ready():
	#debug = get_node("Debug")
	pass

func connect():
	conn = StreamPeerTCP.new()
	conn.connect( ip, port )
	stream = PacketPeerStream.new()
	stream.set_stream_peer( conn )
	if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print_debug(  "Connected to "+ip+" :"+str(port) )
		set_fixed_process(true)
		is_conn = true
		on_connect(stream)
	elif conn.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print_debug(  "Trying to connect "+ip+" :"+str(port) )
		set_fixed_process(true)
	elif conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		print_debug( "Couldn't connect to "+ip+" :"+str(port) )

func disconnect():
	on_disconnect(stream)
	if conn != null:
		conn.disconnect()
	is_conn = false
	set_fixed_process(false)

func set_handler(my_handler):
	if my_handler == null or not my_handler extends ClientHandler:
		print_debug("Invalid handler " + str(my_handler))
		return
	handler = my_handler

func on_connect(stream):
	if handler != null:
		handler.on_connect(stream)
	else:
		print_debug("on_connect: Handler not set")

func on_disconnect(stream):
	if handler != null:
		handler.on_disconnect(stream)
	else:
		print_debug("on_disconnect: Handler not set")

func on_message(stream, message):
	if handler != null:
		handler.on_message(stream, message)
	else:
		print_debug("on_message: Handler not set")
		var cmd = Command.parse(message)
		if cmd != null:
			print_debug(str(cmd.get_msg()))
		else:
			print_debug("Invalid command " + str(message))

func _fixed_process(delta):
	# Still trying to connect
	if !is_conn:
		if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print_debug(  "Connected to "+ip+" :"+str(port) )
			is_conn = true
			on_connect(stream)
		elif conn.get_status() != StreamPeerTCP.STATUS_CONNECTING:
			print_debug( "Server disconnected? " )
			disconnect()
		return
	# Parse data
	while stream.get_available_packet_count() > 0:
		on_message(stream, stream.get_var())
	# Disconnect on network failure
	if conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		print_debug( "Server disconnected? " )
		disconnect()

func send_data(message):
	if not is_conn:
		print_debug( "Unable to send, not connected yet" )
		return
	stream.put_var(message)

func print_debug(mess):
	if debug != null:
		debug.add_text(str(mess))
		debug.newline()
	else:
		print(str(mess))
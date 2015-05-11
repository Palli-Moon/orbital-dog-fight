extends Node

export var port = 4666
export var ip = "127.0.0.1"

var debug

var Command = preload("commands.gd")
var current
var conn
var stream
var is_conn = false
var sent = false

func _ready():
	debug = get_node("Debug")

func connect():
	conn = StreamPeerTCP.new()
	conn.connect( ip, port )
	stream = PacketPeerStream.new()
	stream.set_stream_peer( conn )
	if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print_debug(  "Connected to "+ip+" :"+str(port) )
		set_process(true)
		is_conn = true
	elif conn.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print_debug(  "Trying to connect "+ip+" :"+str(port) )
		set_process(true)
	elif conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		print_debug( "Couldn't connect to "+ip+" :"+str(port) )

func disconnect():
	if conn != null:
		conn.disconnect()
	is_conn = false
	set_process(false)

func _process( delta ):
	# Still trying to connect
	if !is_conn:
		if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print_debug(  "Connected to "+ip+" :"+str(port) )
			is_conn = true
		elif conn.get_status() != StreamPeerTCP.STATUS_CONNECTING:
			print_debug( "Server disconnected? " )
			disconnect()
		return
	# Parse data
	while stream.get_available_packet_count() > 0:
		var data = stream.get_var()
		print_debug( str(data) )
	# Disconnect on network failure
	if conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		print_debug( "Server disconnected? " )
		disconnect()

func print_debug(mess):
	debug.add_text( str(mess) )
	debug.newline()

func send_data(message):
	if not is_conn:
		print_debug( "Unable to send, not connected yet" )
		return
	stream.put_var(message)
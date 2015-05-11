extends Node

export var port = 4666
export var ip = "127.0.0.1"

var debug

var State = preload("state.gd")
var current
var conn
var stream
var is_conn = false
var sent = false


func _ready():
	current = State.PlayerState.new(null)
	debug = get_node("Debug")
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

func _process( delta ):
	if !is_conn:
		if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			print_debug(  "Connected to "+ip+" :"+str(port) )
			is_conn = true
		elif conn.get_status() != StreamPeerTCP.STATUS_CONNECTING:
			print_debug( "Server disconnected? " )
			set_process(false)
		return
	if conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		print_debug( "Server disconnected? " )
		set_process( false )
	while stream.get_available_packet_count() > 0:
		print("omg")
		var data = stream.get_var()
		debug.add_text( str(data) )
	if not sent:
		sent = true
		print("sending")
		send_data("Hello!")
		print("sent")

func print_debug(mess):
	debug.add_text( str(mess) ); debug.newline()

func send_data(message):
	stream.put_var(message)
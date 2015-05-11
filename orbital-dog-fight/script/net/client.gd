extends Node

export var port = 4666
export var ip = "127.0.0.1"

var debug

var State = preload("state.gd")
var current
var conn
var stream
var is_conn = false


func _ready():
	current = State.PlayerState.new(null)
	debug = get_node("Debug")
	conn = StreamPeerTCP.new()
	conn.connect( ip, port )
	if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		debug.add_text( "Connected to "+ip+" :"+str(port) ); debug.newline()
		set_process(true)
		is_conn = true
	elif conn.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		debug.add_text( "Trying to connect "+ip+" :"+str(port) ); debug.newline()
		set_process(true)
	elif conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		debug.add_text( "Couldn't connect to "+ip+" :"+str(port) ); debug.newline()

func _process( delta ):
	if !is_conn:
		if conn.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			debug.add_text( "Connected to "+ip+" :"+str(port) ); debug.newline()
			is_conn = true
			return
		elif conn.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			return
	if conn.get_status() == StreamPeerTCP.STATUS_NONE or conn.get_status() == StreamPeerTCP.STATUS_ERROR:
		debug.add_text( "Server disconnected? " )
		set_process( false )
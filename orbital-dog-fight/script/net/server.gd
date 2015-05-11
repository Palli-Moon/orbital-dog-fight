extends Node

export var host = "127.0.0.1"
export var port = 4567

var server
var debug

var clients = []
var streams = []


func _ready():
	debug = get_node("Label")
	server = TCP_Server.new()
	if server.listen( port, [host] ) == 0:
		debug.add_text( "Server started on port "+str(port) ); debug.newline()
		set_process( true )
	else:
		debug.add_text( "Failed to start server on port "+str(port) ); debug.newline()


func _process( delta ):
	# Check new connections
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append( client )
		streams.append( PacketPeerStream.new() )
		var index = clients.find( client )
		streams[ index ].set_stream_peer( client )
		debug.add_text( "Client has connected!" ); debug.newline()
	# Check if somebody disconnected (we need to flush stream somehow to know if they dropped connection)
	for stream in streams:
		stream.get_available_packet_count()
	for client in clients:
		if !client.is_connected():
			debug.add_text("Client disconnected"); debug.newline()
			var index = clients.find( client )
			clients.remove( index )
			streams.remove( index )



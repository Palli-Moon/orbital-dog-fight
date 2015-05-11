extends Node

export var host = "127.0.0.1"
export var port = 4567

var server
var debug

var Command = preload("commands.gd")
var clients = []
var streams = []

func _ready():
	debug = get_node("Label")

func start():
	server = TCP_Server.new()
	if server.listen( port, [host] ) == 0:
		print_debug("Server started on port "+str(port))
		set_process( true )
	else:
		print_debug("Failed to start server on port "+str(port))

func stop():
	if server != null:
		server.stop()

func _process( delta ):
	# Check new connections
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append( client )
		streams.append( PacketPeerStream.new() )
		var index = clients.find( client )
		streams[ index ].set_stream_peer( client )
		print_debug("Client has connected!")
	# Read incoming data
	for stream in streams:
		while stream.get_available_packet_count() > 0:
			var data = stream.get_var()
			var cmd = Command.parse(data)
			if cmd != null:
				print_debug(str(cmd.get_msg()))
				broadcast(clients[streams.find(stream)].get_connected_host() + " says " + str(data))
			else:
				print_debug("Invalid command " + str(data))
	# Delete disconnected clients
	for client in clients:
		if !client.is_connected():
			print_debug("Client disconnected")
			var index = clients.find( client )
			clients.remove( index )
			streams.remove( index )

func broadcast(message):
	for s in streams:
		s.put_var(message)

func print_debug(mess):
	debug.add_text( str(mess) )
	debug.newline()
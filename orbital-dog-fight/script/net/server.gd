extends Node

export var host = "127.0.0.1"
export var port = 4666
export var max_conns = 4

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

func on_connect(client, stream):
	print_debug("You should extend on_connect(client, stream)")

func on_message(client, stream, message):
	print_debug("You should override on_message(client, stream, message)")
	var cmd = Command.parse(message)
	if cmd != null:
		print_debug(str(cmd.get_msg()))
		broadcast(client.get_connected_host() + " says " + str(message))
	else:
		print_debug("Invalid command " + str(message))

func on_disconnect(client, stream):
	print_debug("You should override on_disconnect(client, stream)")
	pass

func _process( delta ):
	# Check new connections
	if server.is_connection_available():
		var client = server.take_connection()
		if clients.size() >= max_conns:
			client.disconnect()
			print_debug("Server is full")
		else:
			clients.append(client)
			streams.append(PacketPeerStream.new())
			var index = clients.find(client)
			streams[index].set_stream_peer(client)
			print_debug("Client has connected!")
			on_connect(client, streams[index])
	# Read incoming data
	for stream in streams:
		while stream.get_available_packet_count() > 0:
			on_message(clients[streams.find(stream)], stream, stream.get_var())
	# Delete disconnected clients
	for client in clients:
		if !client.is_connected():
			print_debug("Client disconnected")
			var index = clients.find(client)
			on_disconnect(client, streams[index])
			clients.remove(index)
			streams.remove(index)

func broadcast(message):
	for s in streams:
		s.put_var(message)

func send_data(stream, message):
	stream.put_var(message)

func print_debug(mess):
	debug.add_text( str(mess) )
	debug.newline()
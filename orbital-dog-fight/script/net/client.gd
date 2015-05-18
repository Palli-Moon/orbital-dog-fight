extends Node

const UDP_TIMEOUT = 10

export var port = 4666
export var ip = "127.0.0.1"

var debug
var handler = null

var Command = preload("commands.gd")
var conn
var stream
var udpstream
var is_conn = false
var udp_conn = false
var udp_pending = false
var udp_timer = 0
var udp_id = null

class UDPClient:
	var udpstream = PacketPeerUDP.new()
	var handler = null
	
	func _init(host, port):
		udpstream.set_send_address( host, port )
	
	func send_data(data):
		udpstream.put_var(data)
	
	func close():
		udpstream.close()
	
	func process_packets():
		while udpstream.get_available_packet_count() > 0:
			if handler != null:
				print("Received packets!")
				var data = udpstream.get_var()
				print(typeof(data))
				if typeof(data) == TYPE_ARRAY and data.size() == 2 and typeof(data[1]) == TYPE_STRING:
					var parsed = {}
					if parsed.parse_json(data[1]) == 0:
						data[1] = parsed
						handler.on_message(data)
					else:
						print("Unable to decode json: ", data[1])
				else:
					print("Unknown UDP data: ", data)

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
	udpstream = UDPClient.new(ip, port)
	udpstream.handler = self
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
	udp_conn = false
	udp_pending = false
	udp_timer = 0
	udp_id = null
	if udpstream != null:
		udpstream.close()
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

func on_message(message):
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
	# UDP connection pending?
	if udp_pending and udp_timer < OS.get_unix_time():
		# UDP Connection failed
		print("UDP Connection failed, giving up")
		disconnect()
		udp_pending = false
	if udp_pending:
		udpstream.send_data(udp_id)
	# Process UDP packets
	udpstream.process_packets()
	# Parse data
	while stream.get_available_packet_count() > 0:
		var data = stream.get_var()
		if typeof(data) == TYPE_ARRAY and data.size() == 2 and typeof(data[0]) == TYPE_INT:
			if data[0] == 0:
				udp_id = data[1]
				udp_pending = true
				udp_timer = OS.get_unix_time() + UDP_TIMEOUT
			elif data[0] == 1:
				if data[1] == udp_id:
					udp_pending = false
					udp_conn = true
			else:
				on_message(data[1])
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

func _exit_tree():
	disconnect()
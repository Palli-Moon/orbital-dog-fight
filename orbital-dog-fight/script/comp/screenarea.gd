extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

export var timeout = 3.0 # timeout in seconds

var timed_objects = []

class TimedObject:
	var timer = null
	var object = null
	var indicator = null
	var indicator_texture = load("res://assets/img/arrowhite.png")
	
	func _init(timeout, obj):
		print("new timed object created")
		self.object = object
		self.timer = Timer.new()
		self.timer.set_wait_time(timeout)
		self.timer.set_one_shot(true)
		self.timer.connect("timeout", self, "_timeout")
		self.timer.start()
		if (obj.is_in_group("ships")):
			self.indicator = Sprite.new()

	func _timeout():
		print("timeout")
		self.object.hide()
		self.free()

func _ready():
	# Initialization here
	pass

func _on_ScreenExtents_body_enter( body ):
	print("----")
	if (body.is_in_group("ships")):
		print("ship")
		body.show()
	print("entered area")
	pass # replace with function body

func _on_ScreenExtents_body_exit( body ):
	print("----")
	print(body)
	if (body.is_in_group("ships")):
		print("ship")
		timed_objects.append(TimedObject.new(0.5, body))
	print("left area")
	pass # replace with function body

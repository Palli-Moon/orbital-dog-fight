extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

export var timeout = 10.0 # timeout in seconds
export var viewport_scale = 1

var timed_objects = []
var exts

class TimedObject:
	var timer = null
	var object = null
	var indicator = null
	var parent = null
	var indicator_texture = null 
	
	func _init(timeout, obj, parent):
		print("new timed object created")
		self.object = obj
		self.parent = parent
		self.indicator_texture = load("res://assets/img/arrowwhite.png")
		self.timer = Timer.new()
		self.timer.set_wait_time(timeout)
		self.timer.set_one_shot(true)
		self.timer.connect("timeout", self, "_timeout")
		parent.add_child(self.timer)
		self.timer.start()
		if (obj.is_in_group("ships")):
			print("Making new sprite")
			self.indicator = Sprite.new()
			self.indicator.set_texture(self.indicator_texture)
			self.indicator.set_z(4)
			self.indicator.show()
			parent.add_child(self.indicator)

	func _timeout():
		print("timeout")
		if self.object.is_in_group("ships"):
			self.object.die("exp_one")
			print("is dead")
		elif self.object.is_in_group("asteroids"):
			self.object._die()
		clear()
		
	func get_object():
		return self.object
	
	func update(width, height):
		var indicator_pos = Vector2(0.0,0.0)
		if self.indicator != null:
			var obj_pos = self.object.get_pos()
			print(obj_pos)
			indicator_pos = obj_pos
			if obj_pos.x > width*2 - 16:
				indicator_pos.x = width*2 - 16
			elif obj_pos.x < 0:
				indicator_pos.x = 16
			if obj_pos.y > height*2 - 16:
				indicator_pos.y = height*2 - 16
			elif obj_pos.y < 0:
				indicator_pos.y = 16
			self.indicator.set_pos(indicator_pos)
			self.indicator.set_rot(indicator_pos.angle_to_point(obj_pos) + PI/2)
			print(indicator_pos)
			
	func clear():
		self.timer.queue_free()
		if indicator != null:
			self.indicator.queue_free()
		self.parent.timed_objects.remove(self.parent.timed_objects.find(self))

func _ready():
	# Initialization here
	exts = (get_tree().get_root().get_rect().end * viewport_scale)/2
	get_node("ScreenExtents").get_shape(0).set_extents(exts)
	get_node("ScreenExtents").set_pos(exts)
	print(exts)
	set_process(true)
	pass

func _process(delta):
	for obj in timed_objects:
		obj.update(exts.x, exts.y)
	pass
		
func _on_ScreenExtents_body_enter( body ):
	print("----")
	if (body.is_in_group("ships")):
		for timed_obj in timed_objects:
			if timed_obj.get_object() == body:
				timed_obj.clear()
				print("Object removed from list")
	print("entered area")
	pass # replace with function body

func _on_ScreenExtents_body_exit( body ):
	print("----")
	print(body)
	if (body.is_in_group("ships")) and !body.isdying:
		print("ship")
		var obj = TimedObject.new(timeout, body, self)
		print(obj)
		timed_objects.append(obj)
	print("left area")
	pass # replace with function body

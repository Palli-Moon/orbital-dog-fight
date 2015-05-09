tool
extends Node2D

export var star_size = 5
export var star_density = 2.5
export var viewport_scale = 2
export var size_variance = 2

func _ready():
	# Initialization here
	seed(OS.get_unix_time())
	var rect = get_tree().get_root().get_rect()
	var sx = rect.end.x
	var sy = rect.end.y
	var num = sx * viewport_scale * star_density / 100
	
	for i in range(num):
		var thisstarsize = star_size + int(floor((randf()-0.5)*size_variance*2))
		var curr = [(randi() % (int(sx*viewport_scale)+1)), (randi() % (int(sy*viewport_scale)+1))]
		var p = Polygon2D.new()
		add_child(p)
		p.set_z_as_relative(true)
		p.set_z(1)
		curr = Vector2Array([Vector2(curr[0],curr[1]), Vector2(curr[0]+thisstarsize,curr[1]), Vector2(curr[0]+thisstarsize,curr[1]+thisstarsize), Vector2(curr[0],curr[1]+thisstarsize)])
		p.set_polygon(curr)
		p.set_color(Color(255, 255, 255, 255))
	pass



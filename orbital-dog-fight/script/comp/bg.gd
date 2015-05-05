
extends Polygon2D

# member variables here, example:
# var a=2
# var b="textvar"

export var starsize = 5
export var numstars = 25
export var variance = 2

func _ready():
	# Initialization here
	var rect = get_tree().get_root().get_rect()
	var points = Vector2Array([rect.pos, Vector2(rect.pos.x, rect.end.y), rect.end, Vector2(rect.end.x, rect.pos.y)])
	set_polygon(points)
	set_color(Color(0,0,0))
	for i in range(numstars):
		var thisstarsize = starsize + int(floor((randf()-0.5)*variance*2))
		var curr = [randi() % (int(rect.end.x)+1), randi() % (int(rect.end.y)+1)]
		var p = Polygon2D.new()
		add_child(p)
		p.set_z_as_relative(true)
		p.set_z(1)
		curr = Vector2Array([Vector2(curr[0],curr[1]), Vector2(curr[0]+thisstarsize,curr[1]), Vector2(curr[0]+thisstarsize,curr[1]+thisstarsize), Vector2(curr[0],curr[1]+thisstarsize)])
		p.set_polygon(curr)
		p.set_color(Color(255, 255, 255, 255))
	pass



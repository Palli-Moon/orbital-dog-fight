
extends Polygon2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	var rect = get_tree().get_root().get_rect()
	var points = Vector2Array([rect.pos, Vector2(rect.pos.x, rect.end.y), rect.end, Vector2(rect.end.x, rect.pos.y)])
	set_polygon(points)
	set_color(Color(0,0,0))
	pass



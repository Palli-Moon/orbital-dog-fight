tool
extends "res://script/comp/orbital_obj.gd"

export var hitpoints = 100 setget set_hitpoints, get_hitpoints
export(Texture) var asteroid_texture setget set_asteroid_texture, get_asteroid_texture

var curr_hp
var health_bar = null
var heimdallr

func on_ready():
	# Register events
	heimdallr = get_node("/root/Heimdallr")
	heimdallr.register_signal(self, "die")
	# Add to groups
	add_to_group("shootables")
	add_to_group("asteroids")
	add_to_group("sfx")
	get_node("Sprite").set_texture(asteroid_texture)
	set_default_volume(get_node("/root/Demos/Settings").volume * int(!get_node("/root/Demos/Settings").muted))
	pass

func on_spawn():
	curr_hp = hitpoints
	health_bar = get_node("HealthBar")
	health_bar.update()
	set_fixed_process(true)
	pass

func on_collide(body):
	pass

func on_separate(body):
	pass

func _fixed_process(delta):
	health_bar.update_rot()

func set_hitpoints(hp):
	hitpoints = hp

func get_hitpoints():
	return hitpoints

func set_default_volume(value):
	get_node("AsteroidSounds").set_default_volume(value)
	
func _die():
	heimdallr.send_signal(self, "die", [])
	queue_free()

func hit(beam):
	get_node("AsteroidSounds").play("laser-hit2")
	curr_hp -= beam.get_power()
	health_bar.update()
	if curr_hp <= 0:
		_die()

func set_asteroid_texture(tex):
	if has_node("Sprite"):
		get_node("Sprite").set_texture(tex)
	asteroid_texture = tex

func get_asteroid_texture(tex):
	if has_node("Sprite"):
		return get_node("Sprite").get_texture()
	return asteroid_texture

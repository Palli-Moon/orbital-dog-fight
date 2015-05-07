
extends RigidBody2D

export var hitpoints = 100 setget set_hitpoints, get_hitpoints

var curr_hp
var health_bar = null
var heimdallr

func _ready():
	# Register events
	heimdallr = get_node("/root/Heimdallr")
	heimdallr.register_signal(self, "die")
	# Add to groups
	add_to_group("shootables")
	add_to_group("asteroids")
	curr_hp = hitpoints
	health_bar = get_node("HealthBar")
	health_bar.update()
	set_fixed_process(true)
	pass


func _fixed_process(delta):
	health_bar.update_rot()

func set_hitpoints(hp):
	hitpoints = hp

func get_hitpoints():
	return hitpoints

func _die():
	heimdallr.send_signal(self, "die", [])
	queue_free()

func hit(beam):
	get_node("AsteroidSounds").play("laser-hit2")
	curr_hp -= beam.get_power()
	health_bar.update()
	if curr_hp <= 0:
		_die()

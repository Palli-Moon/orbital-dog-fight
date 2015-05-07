extends RigidBody2D

var _colliding_bodies = 0

# Override this method to set your variables before the first spawn
func on_ready():
	pass

# Override this to get contact with other object
func on_collide(body):
	pass

# Override this to set your variables during spawn
func on_spawn():
	pass

func _ready():
	if not get_tree().is_editor_hint():
		on_ready()
		spawn()

func spawn():
	set_collision_enable(true)
	set_cd_enable(true)
	on_spawn()
	pass

func spawn_at(pos, vel, rot):
	set_pos(pos)
	set_linear_velocity(vel)
	set_rot(rot)
	spawn()

func _on_collide(body):
	# The trigger overlap the body
	if get_rid() == body.get_rid():
		return
	_colliding_bodies+=1
	set_layer_mask(1)
	on_collide(body)

func _on_separate(body):
	_colliding_bodies-=1
	if _colliding_bodies < 1:
		set_layer_mask(0)

# Enable/disable our custom ship collision damage detection
func set_cd_enable(enable):
	if not (get_node("Trigger") extends Area2D):
		print("Missing trigger, collision detection will not work")
		return
	if enable:
		get_node("Trigger").connect("body_enter", self, "_on_collide")
		get_node("Trigger").connect("body_exit", self, "_on_separate")
	else:
		get_node("Trigger").disconnect("body_enter", self, "_on_collide")
		get_node("Trigger").disconnect("body_exit", self, "_on_separate")

# Enable/disable the collision of the ship
func set_collision_enable(enable):
	if enable:
		set_collision_mask(1)
		set_layer_mask(1)
	else:
		set_collision_mask(0)
		set_layer_mask(0)
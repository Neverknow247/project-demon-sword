extends Node2D

const MIN_SPEED := 200.0
const MAX_SPEED := 400.0
const SPREAD := TAU / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func explode(explosion_rotation) -> void:
	for child :RigidBody2D in get_children():
		var explosion_velocity = Vector2(randf_range(MIN_SPEED, MAX_SPEED), 0).rotated(explosion_rotation + randf_range(-SPREAD/2, SPREAD/2))
		child.apply_central_impulse(explosion_velocity)

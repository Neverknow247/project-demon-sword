extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum {
	IDLE,
	ATTACKING_PLAYER
}

var state = IDLE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	move_and_slide()

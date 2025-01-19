extends CharacterBody2D

enum {
	IDLE
}
var state := IDLE

@onready var ground_cast = $GroundCast
@onready var idle_timer = $IdleTimer

#@onready var idle_timer = 

@export var speed = 50.0
@export var jump_velocity = -400.0

var idle_direction := -1
var idle_paused := false

func _physics_process(delta):
	match state:
		IDLE:
			if not idle_paused:
				if not ground_cast.is_colliding():
					idle_direction *= -1
				velocity.x = idle_direction * speed
				ground_cast.position.x = 7 * idle_direction
			else:
				velocity.x = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()


func _on_idle_timer_timeout():
	if state == IDLE:
		idle_paused = not idle_paused
		idle_timer.wait_time = randf_range(0.5, 2.0)
		idle_timer.start()

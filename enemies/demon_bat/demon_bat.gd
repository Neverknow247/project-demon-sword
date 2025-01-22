extends CharacterBody2D

class_name DemonBat

@export var speed = 50.0
@export var slam_speed = 100.0

@onready var ceiling_cast = $ceiling_cast

enum {
	RESTING,
	IDLE,
	FOLLOWING,
	SLAM_ATTACK,
	SLAM_RECOVERY,
	DEAD
}

var state = IDLE
var state_process = process_idle

var attack_target = null

func _physics_process(delta):
	state_process.call(delta)
	
	move_and_slide()

func process_idle(delta) -> void:
	pass

func process_following(delta) -> void:
	if ceiling_cast.is_colliding():
		velocity.y = lerp(velocity.y, speed, delta)
		velocity.x = 0
	else:
		velocity.y = 0
		
		velocity.x = sign(attack_target.position.x - position.x) * speed
		
		if abs(attack_target.position.x - position.x) < 8:
			set_state(SLAM_ATTACK)

func process_slam_attack(delta) -> void:
	velocity.x = 0
	if is_on_floor() and $AttackCooldown.is_stopped():
		$AttackCooldown.start()
	else:
		velocity.y = slam_speed

func process_slam_recovery(delta) -> void:
	velocity.x = 0
	velocity.y = -slam_speed
	if ceiling_cast.is_colliding():
		set_state(FOLLOWING)

func set_state(value) -> void:
	state = value
	match state:
		RESTING:
			pass
		IDLE:
			state_process = process_idle
		FOLLOWING:
			state_process = process_following
		SLAM_ATTACK:
			state_process = process_slam_attack
		SLAM_RECOVERY:
			state_process = process_slam_recovery
		DEAD:
			pass


func _on_attack_cooldown_timeout():
	set_state(SLAM_RECOVERY)

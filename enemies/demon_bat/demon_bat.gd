extends CharacterBody2D

class_name DemonBat

@export var speed = 50.0
@export var slam_speed = 150.0
@export var health := 2
@export var detect_player := true:
	set(value):
		detect_player = value
		if detect_player and detection_area.get_overlapping_bodies().size() > 0:
			attack_target = detection_area.get_overlapping_bodies()[0]
			state_process = process_following

@onready var ceiling_cast = $ceiling_cast
@onready var animation_player = $animation_player
@onready var hurt_box_collision_shape = $hurtbox/collision_shape_2d
@onready var detection_area = $detection_area
@onready var sprite_2d = $sprite_2d
@onready var rise_cast = $rise_cast
@onready var hurt_sound = $hurt_sound

#enum {
	#RESTING,
	#IDLE,
	#FOLLOWING,
	#SLAM_ATTACK,
	#SLAM_RECOVERY,
	#CRAWL_FOLLOW,
	#DEAD
#}

#var state = IDLE
var state_process = process_sleep

var attack_target = null

func _ready() -> void:
	set_state(process_sleep)

func _physics_process(delta):
	state_process.call(delta)
	
	move_and_slide()

func process_idle(delta) -> void:
	animation_player.play("flying")
	velocity = Vector2.ZERO

func process_sleep(delta) -> void:
	animation_player.play("sleep")
	velocity = Vector2.ZERO

func process_following(delta) -> void:
	animation_player.play("flying")
	
	if ceiling_cast.is_colliding():
		velocity.y = lerp(velocity.y, speed, delta)
		velocity.x = 0
	elif not rise_cast.is_colliding():
		velocity.y = lerp(velocity.y, -speed, delta)
		velocity.x = 0
	else:
		velocity.y = 0
		
		velocity.x = sign(attack_target.global_position.x - global_position.x) * speed
		
		if abs(attack_target.global_position.x - global_position.x) < 8:
			set_state(process_slam_attack)
	
	if velocity.x < 0:
		sprite_2d.flip_h = true
	elif velocity.x > 0:
		sprite_2d.flip_h = false

func process_slam_attack(delta) -> void:
	animation_player.play("slam")
	
	velocity.x = 0
	if is_on_floor() and $attack_cooldown.is_stopped():
		$attack_cooldown.start()
	else:
		velocity.y = slam_speed

func process_slam_recovery(delta) -> void:
	velocity.x = 0
	velocity.y = -slam_speed
	if ceiling_cast.is_colliding():
		set_state(process_following)

func process_hurt(delta) -> void:
	animation_player.play("hurt")

func set_state(value) -> void:
	state_process = value
	
	if state_process == process_slam_attack:
		$hitbox/collision_shape_2d.set_deferred("disabled", false)
	else:
		$hitbox/collision_shape_2d.set_deferred("disabled", true)
	
	hurt_box_collision_shape.set_deferred("disabled", state_process == process_sleep)


func _on_attack_cooldown_timeout():
	set_state(process_slam_recovery)


func _on_hurtbox_hurt(hitbox, damage):
	health -= damage
	
	var blood_spray = preload("res://particles/blood_spray.tscn").instantiate()
	blood_spray.set_up(get_parent(), hurt_box_collision_shape.global_position, hitbox.global_position)
	
	print("bat hit")
	if health <= 0:
		var gib = preload("res://enemies/demon_bat/demon_bat_gib_explosion.tscn").instantiate()
		get_parent().call_deferred("add_child", gib)
		gib.set_deferred("global_position", global_position)
		gib.explode(blood_spray.rotation)
		
		queue_free()
	else:
		velocity = (hurt_box_collision_shape.global_position - hitbox.global_position).normalized() * 80
		set_state(process_hurt)
		
		hurt_sound.play()


func _on_detection_area_body_entered(body):
	if detect_player:
		attack_target = body
		set_state(process_following)
		state_process = process_following


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hurt":
		set_state(process_following)

extends Area2D

class_name Eye

@onready var shot_cooldown = $shot_cooldown
@onready var animation_player = $animation_player
@onready var detection_area = $detection_area
@onready var hurt_box_collision_shape = $hurtbox/collision_shape_2d

var state_process = process_idle
var attack_target = null

@export var shots_before_teleport := 1
@export var shot_cooldown_time := 1.0
@export var bullet_speed := 100.0
@export var in_wall_speed := 50.0
@export var follow_speed := 50.0
@export var detect_player := true:
	set(value):
		detect_player = value
		if detect_player and detection_area.get_overlapping_bodies().size() > 0:
			attack_target = detection_area.get_overlapping_bodies()[0]
			state_process = process_teleport

@export var health := 1

var shots_fired := 0

func _ready():
	state_process = process_sleep

func _physics_process(delta):
	state_process.call(delta)
	

func process_idle(delta) -> void:
	pass

func process_attack(delta) -> void:
	if get_overlapping_bodies().size() > 0:
		global_position += (attack_target.global_position - global_position).normalized() * in_wall_speed * delta
	else:
		global_position -= (attack_target.global_position - global_position).normalized() * follow_speed * delta
		if shot_cooldown.is_stopped():
			if shots_fired < shots_before_teleport:
				shoot()
			else:
				set_state(process_teleport)
			#shoot()
	

func process_teleport(delta) -> void:
	pass

func shoot() -> void:
	shot_cooldown.wait_time = shot_cooldown_time
	shot_cooldown.start()
	
	var bullet = preload("res://enemies/enemy_projectile.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.velocity = (attack_target.global_position - global_position).normalized() * bullet_speed
	
	shots_fired += 1

func process_sleep(delta) -> void:
	animation_player.play("sleep")
	#velocity = Vector2.ZERO

func process_hurt(deltaa) -> void:
	animation_player.play("hurt")

func set_state(value) -> void:
	state_process = value
	if state_process == process_attack:
		shots_fired = 0
		animation_player.play("idle")
		#shoot()
	elif state_process == process_teleport:
		animation_player.play("teleport")
	else:
		shot_cooldown.stop()
		animation_player.play("idle")
	
	hurt_box_collision_shape.set_deferred("disabled", state_process == process_sleep)


func _on_shot_cooldown_timeout():
	#if state_process == 
	#if shots_fired < shots_before_teleport:
		#shoot()
	#else:
		#set_state(process_teleport)
		##shots
	pass # Replace with function body.

func teleport() -> void:
	global_position = attack_target.global_position
	global_position.x += randf_range(-100, 100)
	global_position.y += randf_range(-100, -16)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "teleport":
		set_state(process_attack)
	elif anim_name == "hurt":
		set_state(process_teleport)


func _on_hurtbox_hurt(hitbox, damage):
	if state_process == process_teleport:
		return
	
	var blood_spray = preload("res://particles/blood_spray.tscn").instantiate()
	blood_spray.set_up(get_parent(), hurt_box_collision_shape.global_position, hitbox.global_position)
	
	health -= damage
	if health <= 0:
		var gib = preload("res://enemies/eye/eye_gib_explosion.tscn").instantiate()
		get_parent().call_deferred("add_child", gib)
		gib.set_deferred("global_position", global_position)
		gib.explode(blood_spray.rotation)
		
		queue_free()
	else:
		set_state(process_hurt)
		


func _on_detection_area_body_entered(body):
	if detect_player and attack_target != body:
		attack_target = body
		set_state(process_teleport)

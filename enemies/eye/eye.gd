extends Area2D

class_name Eye

@onready var shot_cooldown = $shot_cooldown
@onready var animation_player = $animation_player

var state_process = process_idle
var attack_target = null

@export var shots_before_teleport := 1
@export var shot_cooldown_time := 1.0
@export var bullet_speed := 100.0
@export var in_wall_speed := 50.0
@export var follow_speed := 50.0

@export var health := 1

var shots_fired := 0

func _physics_process(delta):
	state_process.call(delta)
	

func process_idle(delta) -> void:
	pass

func process_attack(delta) -> void:
	if get_overlapping_bodies().size() > 0:
		position += (attack_target.position - position).normalized() * in_wall_speed * delta
	else:
		position -= (attack_target.position - position).normalized() * follow_speed * delta
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
	bullet.position = position
	bullet.velocity = (attack_target.position - position).normalized() * bullet_speed
	
	shots_fired += 1

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


func _on_shot_cooldown_timeout():
	#if state_process == 
	#if shots_fired < shots_before_teleport:
		#shoot()
	#else:
		#set_state(process_teleport)
		##shots
	pass # Replace with function body.

func teleport() -> void:
	position = attack_target.position
	position.x += randf_range(-100, 100)
	position.y += randf_range(-100, -16)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "teleport":
		set_state(process_attack)


func _on_hurtbox_hurt(hitbox, damage):
	health -= damage
	if health <= 0:
		queue_free()

extends CharacterBody2D

class_name DeadCultist

var stats = Stats

#enum {
	#RESTING,
	#IDLE,
	#FOLLOWING,
	#ATTACKING,
	#DEAD
#}
var state_process = process_sleep

@onready var ground_cast = $ground_cast
@onready var idle_timer = $idle_timer
@onready var animation_player = $animation_player
@onready var boid_area = $boid_area
@onready var hurt_box = $hurt_box
@onready var hurt_box_collision_shape = $hurt_box/collision_shape_2D
@onready var detection_area = $detection_area
@onready var hurt_sound = $hurt_sound

#@onready var idle_timer = 

@export var speed = 80.0
@export var health := 3.0
@export var gravity := 90.0
@export var detect_player := true:
	set(value):
		detect_player = value
		if detect_player and detection_area.get_overlapping_bodies().size() > 0:
			attack_target = detection_area.get_overlapping_bodies()[0]
			state_process = process_following

var idle_direction := -1
var idle_paused := false

var attack_target = null

const ATTACK_DISTANCE := 42

func _ready() -> void:
	set_state(process_sleep)
	if stats["save_data"]["items"]["sword"]:
		detect_player = true

func _physics_process(delta):
	state_process.call(delta)
	
	move_and_slide()

func process_idle(delta:float) -> void:
	if not idle_paused:
		if not ground_cast.is_colliding():
			idle_direction *= -1
		velocity.x = idle_direction * speed
		ground_cast.position.x = 7 * idle_direction
	else:
		velocity.x = 0
	
	if velocity.x == 0:
		animation_player.play("idle")
	else:
		animation_player.play("run")
	
	velocity.y += gravity * delta
	
	updated_sprite_direction()

func updated_sprite_direction() -> void:
	if velocity.x > 0:
		set_flip(false)
	elif velocity.x < 0:
		set_flip(true)

func process_attack(delta:float) -> void:
	animation_player.play("attack")
	velocity.x = 0
	velocity.y += gravity * delta

func process_following(delta:float) -> void:
	if attack_target == null:
		set_state(process_idle)
		return
	
	if not idle_paused:
		var attack_target_direction = sign(attack_target.global_position.x - global_position.x)
		
		if not ground_cast.is_colliding():
			velocity.x = 0
		else:
			var attack_target_distance = abs(attack_target.global_position.x - global_position.x)
			
			if attack_target_distance <= ATTACK_DISTANCE and randi() % 8 == 0:
				set_state(process_attack)
				return
			
			var closest_neighbor_pos_x
			var shortest_neighbor_distance = null
			for enemy in boid_area.get_overlapping_bodies():
				if enemy == self:
					continue
				if enemy is DeadCultist:
					if enemy.state_process == enemy.process_sleep:
						continue
					var neighbor_distance = abs(enemy.position.x - position.x)
					if shortest_neighbor_distance == null or neighbor_distance < shortest_neighbor_distance:
						closest_neighbor_pos_x = enemy.global_position.x
						shortest_neighbor_distance = neighbor_distance
			
			if attack_target_distance > 16 and (shortest_neighbor_distance == null or attack_target_distance < shortest_neighbor_distance):
				velocity.x = lerp(velocity.x, attack_target_direction * speed, delta * 2)
			elif shortest_neighbor_distance != null:
				velocity.x = lerp(velocity.x, -sign(closest_neighbor_pos_x - global_position.x) * speed * 0.5, delta)
			else:
				velocity.x = 0
			
		ground_cast.position.x = 7 * attack_target_direction
	else:
		velocity.x = 0
	
	velocity.y += gravity * delta
	
	if velocity.x == 0:
		animation_player.play("idle")
	else:
		animation_player.play("run")
	
	updated_sprite_direction()

func process_hurt(delta: float) -> void:
	velocity = Vector2.ZERO

func process_sleep(delta) -> void:
	animation_player.play("sleep")
	velocity.x = 0
	velocity.y += gravity * delta

func _on_idle_timer_timeout():
	if state_process == process_idle:
		idle_paused = not idle_paused
		idle_timer.wait_time = randf_range(0.5, 2.0)
		idle_timer.start()

func set_state(value) -> void:
	state_process = value
	
	hurt_box_collision_shape.set_deferred("disabled", state_process == process_sleep)

func set_flip(value) -> void:
	$sprite.flip_h = value
	if value == false:
		$flip_helper.scale.x = 1
	else:
		$flip_helper.scale.x = -1


func _on_animation_player_animation_finished(anim_name):
	if state_process == process_attack and anim_name == "attack":
		set_state(process_following)
	elif anim_name == "hurt":
		set_state(process_following)


func _on_hurt_box_hurt(hitbox, damage):
	var blood_spray = preload("res://particles/blood_spray.tscn").instantiate()
	blood_spray.set_up(get_parent(), hurt_box.global_position, hitbox.global_position)
	
	animation_player.play("hurt")
	set_state(process_hurt)
	
	health -= damage
	if health <= 0:
		var gib = preload("res://enemies/dead_cultist/dead_cultist_gib_explosion.tscn").instantiate()
		get_parent().call_deferred("add_child", gib)
		gib.set_deferred("global_position", global_position)
		gib.explode(blood_spray.rotation)
		
		queue_free()
	else:
		hurt_sound.play()


func _on_detection_area_body_entered(body):
	if detect_player:
		attack_target = body
		set_state(process_following)
		state_process = process_following

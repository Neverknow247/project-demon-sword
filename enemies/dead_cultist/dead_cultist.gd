extends CharacterBody2D

class_name DeadCultist

#enum {
	#RESTING,
	#IDLE,
	#FOLLOWING,
	#ATTACKING,
	#DEAD
#}
var state_process = process_idle

@onready var ground_cast = $ground_cast
@onready var idle_timer = $idle_timer
@onready var animation_player = $animation_player
@onready var boid_area = $boid_area

#@onready var idle_timer = 

@export var speed = 40.0
@export var health := 3.0

var idle_direction := -1
var idle_paused := false

var attack_target = null

func _ready() -> void:
	pass

func _physics_process(delta):
	state_process.call(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func process_idle(delta:float) -> void:
	animation_player.play("idle")
	if not idle_paused:
		if not ground_cast.is_colliding():
			idle_direction *= -1
		velocity.x = idle_direction * speed
		ground_cast.position.x = 7 * idle_direction
	else:
		velocity.x = 0
	
	if velocity.x > 0:
		pass

func process_attack(delta:float) -> void:
	animation_player.play("attack")
	velocity.x = 0

func process_following(delta:float) -> void:
	animation_player.play("idle")
	
	if attack_target == null:
		set_state(process_idle)
		return
	
	if not idle_paused:
		var attack_target_direction = sign(attack_target.position.x - position.x)
		
		if not ground_cast.is_colliding():
			velocity.x = 0
		else:
			var attack_target_distance = abs(attack_target.position.x - position.x)
			
			if attack_target_distance <= 8 and randi() % 8 == 0:
				set_state(process_attack)
				return
			
			var closest_neighbor_pos_x
			var shortest_neighbor_distance = null
			for enemy in boid_area.get_overlapping_bodies():
				if enemy == self:
					continue
				if enemy is DeadCultist:
					var neighbor_distance = abs(enemy.position.x - position.x)
					if shortest_neighbor_distance == null or neighbor_distance < shortest_neighbor_distance:
						closest_neighbor_pos_x = enemy.position.x
						shortest_neighbor_distance = neighbor_distance
			
			if attack_target_distance > 16 and (shortest_neighbor_distance == null or attack_target_distance < shortest_neighbor_distance):
				velocity.x = lerp(velocity.x, attack_target_direction * speed, delta)
			elif shortest_neighbor_distance != null:
				velocity.x = lerp(velocity.x, -sign(closest_neighbor_pos_x - position.x) * speed * 0.5, delta)
			else:
				velocity.x = 0
			
		ground_cast.position.x = 7 * attack_target_direction
	else:
		velocity.x = 0

func _on_idle_timer_timeout():
	if state_process == process_idle:
		idle_paused = not idle_paused
		idle_timer.wait_time = randf_range(0.5, 2.0)
		idle_timer.start()

func set_state(value) -> void:
	state_process = value

func set_flip(value) -> void:
	$sprite.flip_h = value
	if value == false:
		$flip_helper.scale.x = 1
	else:
		$flip_helper.scale.x = -1


func _on_animation_player_animation_finished(anim_name):
	if state_process == process_attack and anim_name == "attack":
		set_state(process_following)


func _on_hurt_box_hurt(hitbox, damage):
	health -= damage
	if health <= 0:
		queue_free()

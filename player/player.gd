extends CharacterBody2D

var stats = Stats
var sounds = Sounds
var rng = RandomNumberGenerator.new()

const sword_arm_sprite = preload("res://assets/art/player/player_sword_arm.png")
const cannon_arm_sprite = preload("res://assets/art/player/player_cannon_arm.png")
const cannon_arm_aimed_sprite = preload("res://assets/art/player/player_cannon_arm_aimed.png")
#const spear_legs_sprite = preload()
const right_arm_sprite = preload("res://assets/art/player/player_right_arm.png")
const left_arm_sprite = preload("res://assets/art/player/player_left_arm.png")
const legs_sprite = preload("res://assets/art/player/player_legs.png")

var current_velocity = 0.0
@export var default_max_velocity = 220
@export var max_velocity : float = 220.0
@export var acceleration = 1500
@export var friction = 1500
@export var wall_friction = .02
@export var ground_friction = .2
@export var air_friction = 1500
@export var sword_air_friction = 250
@export var jump_force = 520
@export var fall_bonus = .05
@export var default_max_fall_velocity : float = 350.0
@export var max_fall_velocity = 350
@export var gravity = 1100
@export var default_wall_slide_speed = 350
@export var max_wall_slide_speed = 350
@export var wall_slide_speed = 350
#@export var default_wall_slide_speed = 0
#@export var max_wall_slide_speed = 0
#@export var wall_slide_speed = 0
@export var wall_slide_bonus = .1

@onready var sprites = $sprites
#@onready var player_left_arm = $sprites/player_left_arm
@onready var player_left_arm = $sprites/cannon/rotation_point/player_left_arm
@onready var player_legs = $sprites/player_legs
@onready var player_head = $sprites/player_head
@onready var player_torso = $sprites/player_torso
@onready var player_right_arm = $sprites/player_right_arm
@onready var animation_player = $AnimationPlayer
@onready var hit_animator = $hit_animator
@onready var cannon = $sprites/cannon

@onready var ground_collision_1 = $sprites/ground_sword_hitbox_1/ground_collision_1
@onready var air_collision_1 = $sprites/air_sword_hitbox_1/air_collision_1
@onready var air_collision_2 = $sprites/air_sword_hitbox_2/air_collision_2

@onready var attack_cooldown_timer = $attack_cooldown_timer
@onready var cannon_cooldown_timer = $cannon_cooldown_timer
@onready var coyote_jump_timer = $coyote_jump_timer
@onready var coyote_wall_timer = $coyote_wall_timer
@onready var jump_timer = $jump_timer
@onready var jump_buffer_timer = $jump_buffer_timer
@onready var drop_timer = $drop_timer

var state = "move_state"
var just_jumped = false
var jump_buffer = false
var invincible = false
var damages = []
var last_facing = 1
var sword_action_pressed = false
var sword_action_number = 0
var aimed_cannon_mode = false
@export var sword_arm_unlocked = false
@export var cannon_arm_unlocked = false
@export var spear_legs_unlocked = false

@warning_ignore("unused_signal")
signal hit_door(door)

func _ready():
	rng.randomize()
	check_sword_arm_unlocked()
	check_cannon_arm_unlocked()

func _physics_process(delta):
	current_velocity = abs(velocity.x)
	var callable = Callable(self,state)
	callable.call(delta)

func check_sword_arm_unlocked():
	if stats["save_data"]["items"]["sword"] || sword_arm_unlocked == true:
		sword_arm_unlocked = true
		player_right_arm.texture = sword_arm_sprite
		sounds.play_music("after_sword")
	else:
		player_right_arm.texture = right_arm_sprite
		sounds.play_music("before_sword")

func check_cannon_arm_unlocked():
	if stats["save_data"]["items"]["cannon"] || cannon_arm_unlocked == true:
		cannon_arm_unlocked = true
		player_left_arm.texture = cannon_arm_sprite
	else:
		player_left_arm.texture = left_arm_sprite

func move_state(delta):
	sword_action_pressed = false
	sword_action_number = 0
	apply_gravity(delta)
	var input_axis = get_input_axis()
	if is_moving(input_axis):
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		apply_acceleration(delta,input_axis)
	else:
		apply_friction(delta)
	jump_check()
	drop_check()
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall()
	fall_bonus_check()
	update_animations(input_axis)
	sword_check()
	cannon_check(input_axis)
	var wall = false
	move_and_slide()
	if was_on_wall and is_on_wall():
		wall = wall_check()
	if !was_on_floor and is_on_floor():
		apply_squash()
		update_left_arm_animations()
		animation_player.play("idle")
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall and wall != false:
		coyote_wall_timer.start()
	reset_velocity_check()

func apply_gravity(delta):
	velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func get_input_axis():
	var input_axis = 0
	if Input.get_axis("c_left","c_right") != 0:
		input_axis = Input.get_axis("c_left","c_right")
	if Input.get_axis("left","right") != 0:
		input_axis = Input.get_axis("left","right")
	if input_axis > .25:
		input_axis = 1
	elif input_axis < -.25:
		input_axis = -1
	return signi(input_axis)

func is_moving(input_axis):
	return input_axis != 0

func apply_acceleration(delta,input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func jump_check():
	if is_on_floor():
		if jump_buffer:
			jump(jump_force)
			jump_buffer = false
			return
	if coyote_wall_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("c_jump"):
			jump(jump_force)
	elif is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("c_jump"):
			jump(jump_force)
	elif not is_on_floor():
		@warning_ignore("integer_division")
		if just_jumped and (Input.is_action_just_released("jump") || Input.is_action_just_released("c_jump")) and velocity.y < -jump_force/10:
			@warning_ignore("integer_division")
			velocity.y = -jump_force / 8
		if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("c_jump"):
			jump_buffer_timer.start()
			jump_buffer = true

func jump(force):
	apply_stretch()
	just_jumped = true
	jump_timer.start()
	velocity.y = -force
	update_left_arm_animations()

func drop_check():
	if Input.is_action_pressed("down") || Input.is_action_pressed("c_down"):
		set_collision_mask_value(8,false)
		drop_timer.start()

func sword_check():
	if !sword_arm_unlocked:
		return
	if (Input.is_action_just_pressed("sword") || Input.is_action_just_pressed("c_sword")) and attack_cooldown_timer.time_left<=0:
		attack_cooldown_timer.start()
		#sword_action_number += 1
		if is_on_floor():
			animation_player.play("sword_ground_attack_1")
		else:
			animation_player.play("sword_air_attack_1")
		state = "sword_state"

@warning_ignore("unused_parameter")
func cannon_check(input_axis):
	if !cannon_arm_unlocked:
		return
	var rotated = check_rotate_cannon()
	if (Input.is_action_just_pressed("cannon") || Input.is_action_just_pressed("c_cannon")) and cannon_cooldown_timer.time_left<=0:
		rotate_cannon(rotated)
		cannon_cooldown_timer.start()
		player_left_arm.texture = cannon_arm_aimed_sprite
		aimed_cannon_mode = true
		cannon.fire_cannon(last_facing,rotated)
	elif aimed_cannon_mode == true:
		rotate_cannon(rotated)
	else:
		rotate_cannon(0)

func check_rotate_cannon():
	if Input.is_action_pressed("up") || Input.is_action_pressed("c_up"):
		return -90
	elif (Input.is_action_pressed("down") || Input.is_action_pressed("c_down")) and not is_on_floor():
		return 90
	else:
		return 0

func rotate_cannon(amount_rotated):
	cannon.rotation_point.rotation_degrees = amount_rotated

func fall_bonus_check():
	if is_on_floor():
		max_fall_velocity = default_max_fall_velocity
	else:
		if Input.is_action_pressed("down") || Input.is_action_pressed("c_down"):
			max_fall_velocity += fall_bonus

func update_animations(input_vector):
	var facing = input_vector
	if facing != 0:
		if last_facing != facing:
			update_left_arm_animations()
		last_facing = facing
		#player_left_arm.flip_h = facing != 1
		player_legs.flip_h = facing != 1
		player_head.flip_h = facing != 1
		player_torso.flip_h = facing != 1
		player_right_arm.flip_h = facing != 1
		cannon.scale.x = facing
		$sprites/ground_sword_hitbox_1.scale.x = facing
		$sprites/air_sword_hitbox_1.scale.x = facing
		$sprites/air_sword_hitbox_2.scale.x = facing
		$Camera2D.drag_horizontal_offset = float(facing/20.0)
	if not is_on_floor():
		animation_player.stop()
		disable_collisions()
		if velocity.y <= 0:
			player_left_arm.frame = 10
			player_legs.frame = 10
			player_head.frame = 10
			player_torso.frame = 10
			player_right_arm.frame = 10
		else:
			player_left_arm.frame = 11
			player_legs.frame = 11
			player_head.frame = 11
			player_torso.frame = 11
			player_right_arm.frame = 11
	elif input_vector != 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func disable_collisions():
	ground_collision_1.disabled = true
	air_collision_1.disabled = true
	air_collision_2.disabled = true

func wall_check():
	return
	#@warning_ignore("unreachable_code")
	#if not is_on_floor() and is_on_wall():
		#state = "wall_state"
		#max_velocity = max(max_velocity-wall_friction,default_max_velocity)

func reset_velocity_check():
	if is_on_floor():
		max_velocity = max(max_velocity-ground_friction,default_max_velocity)

func wall_state(delta):
	#animation_player.stop()
	var wall_normal = sign(get_wall_normal().x)
	if wall_normal != 0:
		player_left_arm.flip_h = wall_normal != 1
		player_legs.flip_h = wall_normal != 1
		player_head.flip_h = wall_normal != 1
		player_torso.flip_h = wall_normal != 1
		player_right_arm.flip_h = wall_normal != 1
	if velocity.y <= 0:
		pass
		#sprite.frame = up_frame
	else:
		pass
		#sprite.frame = down_frame
	velocity.y = clampf(velocity.y, -max_fall_velocity, max_fall_velocity)
	wall_jump_check(wall_normal)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta)

@warning_ignore("unused_parameter")
func wall_jump_check(wall_axis):
	if jump_buffer:
		pass
	if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("c_jump"):
		jump(jump_force)

func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("down") || Input.is_action_pressed("c_down"):
		slide_speed = max_fall_velocity
		max_fall_velocity += wall_slide_bonus
	else:
		slide_speed = wall_slide_speed
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)

func wall_detach(delta):
	if Input.is_action_just_pressed("right") || Input.is_action_just_pressed("c_right"):
		velocity.x = acceleration * delta
		coyote_wall_timer.start()
		state = "move_state"
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("c_left"):
		velocity.x = -acceleration * delta
		coyote_wall_timer.start()
		state = "move_state"
	if not is_on_wall() and not is_on_ceiling() or is_on_floor():
		state = "move_state"

func sword_state(delta):
	#velocity.y = 0
	apply_gravity(delta)
	var input_axis = get_input_axis()
	if is_moving(input_axis):
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		apply_acceleration(delta,input_axis)
	else:
		apply_friction(delta)
	jump_check()
	update_left_arm_animations()
	move_and_slide()
	#if (Input.is_action_just_pressed("sword") || Input.is_action_just_pressed("c_sword")) and sword_action_pressed == false:
		#sword_action_pressed = true
		#sword_action_number += 1
	if not animation_player.is_playing() or !animation_player.current_animation.contains("sword"):
		state = "move_state"
	#else:
		#print(animation_player.current_animation)
		#This code is if I can animate combos
		#if sword_action_pressed == false or sword_action_number > 3:
			#state = "move_state"
		#else:
			#sword_action_pressed = false
			#if is_on_floor():
				#animation_player.play("sword_ground_attack_%s" %[sword_action_number])
			#else:
				#animation_player.play("sword_air_attack_%s" %[sword_action_number])

func update_left_arm_animations():
	aimed_cannon_mode = false
	if cannon_arm_unlocked:
		player_left_arm.texture = cannon_arm_sprite
	else:
		player_left_arm.texture = left_arm_sprite

func apply_stretch():
	var tween = get_tree().create_tween()
	tween.tween_property(sprites,"scale",Vector2(.8,1.2),.1)
	tween.tween_property(sprites,"scale",Vector2(1,1),.15)

func apply_squash():
	var tween = get_tree().create_tween()
	tween.tween_property(sprites,"scale",Vector2(1.2,.8),.1)
	tween.tween_property(sprites,"scale",Vector2(1,1),.15)

func _on_jump_timer_timeout():
	just_jumped = false

func _on_jump_buffer_timer_timeout():
	jump_buffer = false

func _on_drop_timer_timeout():
	set_collision_mask_value(8,true)

func _on_hurtbox_hurt(hitbox, damage):
	if !hit_animator.is_playing():
		hit_animator.play("blink")
		stats.health -= damage

func _on_delete_me_late_area_entered(area):
	if area.item_name == "sword":
		stats["save_data"]["items"]["sword"] = true
		sword_arm_unlocked = true
		check_sword_arm_unlocked()
		area.queue_free()
	if area.item_name == "cannon":
		stats["save_data"]["items"]["cannon"] = true
		cannon_arm_unlocked = true
		check_cannon_arm_unlocked()
		area.queue_free()
		

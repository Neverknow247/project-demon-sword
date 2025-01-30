extends CharacterBody2D

var rng = RandomNumberGenerator.new()

const sword_arm_sprite = preload("res://assets/art/player/player_sword_arm.png")
#const cannon_arm_sprite = preload()
#const spear_legs_sprite = preload()
const right_arm_sprite = preload("res://assets/art/player/player_right_arm.png")
const left_arm_sprite = preload("res://assets/art/player/player_left_arm.png")
const legs_sprite = preload("res://assets/art/player/player_legs.png")

var current_velocity = 0.0
@export var default_max_velocity = 220
@export var max_velocity : float = 220.0
@export var acceleration = 1500
@export var friction = 1300
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
@onready var player_left_arm = $sprites/player_left_arm
@onready var player_legs = $sprites/player_legs
@onready var player_head = $sprites/player_head
@onready var player_torso = $sprites/player_torso
@onready var player_right_arm = $sprites/player_right_arm
@onready var animation_player = $AnimationPlayer

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
@export var sword_arm_unlocked = false
@export var cannon_arm_unlocked = false
@export var spear_legs_unlocked = false

func _ready():
	rng.randomize()
	check_sword_arm_unlocked()

func _physics_process(delta):
	current_velocity = abs(velocity.x)
	var callable = Callable(self,state)
	callable.call(delta)

func check_sword_arm_unlocked():
	if sword_arm_unlocked:
		player_right_arm.texture = sword_arm_sprite
	else:
		player_right_arm.texture = right_arm_sprite

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
	var wall = false
	move_and_slide()
	if was_on_wall and is_on_wall():
		wall = wall_check()
	if !was_on_floor and is_on_floor():
		#apply_squash()
		pass
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
		if state == "sword_state":
			velocity.x = move_toward(velocity.x, 0, sword_air_friction * delta)
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
		if just_jumped and (Input.is_action_just_released("jump") || Input.is_action_just_released("c_jump")) and velocity.y < -jump_force/10:
			velocity.y = -jump_force / 8
		if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("c_jump"):
			jump_buffer_timer.start()
			jump_buffer = true

func jump(force):
	#apply_stretch()
	just_jumped = true
	jump_timer.start()
	velocity.y = -force

func drop_check():
	if Input.is_action_pressed("down") || Input.is_action_pressed("c_down"):
		set_collision_mask_value(8,false)
		drop_timer.start()

func sword_check():
	if !sword_arm_unlocked:
		return
	if Input.is_action_just_pressed("sword") || Input.is_action_just_pressed("c_sword"):
		#sword_action_number += 1
		if is_on_floor():
			animation_player.play("sword_ground_attack_1")
		else:
			animation_player.play("sword_air_attack_1")
		state = "sword_state"

func fall_bonus_check():
	if is_on_floor():
		max_fall_velocity = default_max_fall_velocity
	else:
		if Input.is_action_pressed("down") || Input.is_action_pressed("c_down"):
			max_fall_velocity += fall_bonus

func update_animations(input_vector):
	var facing = input_vector
	if facing != 0:
		last_facing = facing
		player_left_arm.flip_h = facing != 1
		player_legs.flip_h = facing != 1
		player_head.flip_h = facing != 1
		player_torso.flip_h = facing != 1
		player_right_arm.flip_h = facing != 1
		$sprites/ground_sword_hitbox_1.scale.x = facing
		$sprites/air_sword_hitbox_1.scale.x = facing
		$sprites/air_sword_hitbox_2.scale.x = facing
		$Camera2D.drag_horizontal_offset = float(facing/20.0)
	if not is_on_floor():
		animation_player.stop()
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

func wall_check():
	return
	if not is_on_floor() and is_on_wall():
		state = "wall_state"
		max_velocity = max(max_velocity-wall_friction,default_max_velocity)

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
	apply_friction(delta)
	move_and_slide()
	#if (Input.is_action_just_pressed("sword") || Input.is_action_just_pressed("c_sword")) and sword_action_pressed == false:
		#sword_action_pressed = true
		#sword_action_number += 1
	if not animation_player.is_playing():
		state = "move_state"
		#This code is if I can animate combos
		#if sword_action_pressed == false or sword_action_number > 3:
			#state = "move_state"
		#else:
			#sword_action_pressed = false
			#if is_on_floor():
				#animation_player.play("sword_ground_attack_%s" %[sword_action_number])
			#else:
				#animation_player.play("sword_air_attack_%s" %[sword_action_number])


func _on_jump_timer_timeout():
	just_jumped = false

func _on_jump_buffer_timer_timeout():
	jump_buffer = false

func _on_drop_timer_timeout():
	set_collision_mask_value(8,true)

extends StaticBody2D

@onready var animation_player = $animation_player
@onready var ground_cast = $ground_cast
@onready var sprite_2d = $sprite_2d

@export var health := 3
@export var gravity := 90.0

var falling := false
var landed := false

var velocity := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if falling:
		velocity.y += gravity * delta
		global_position += velocity * delta
		if ground_cast.is_colliding():
			falling = false
			landed = true
			
			global_position.y = ground_cast.get_collision_point().y - sprite_2d.get_rect().size.y / 2 + 16

func _on_hurtbox_hurt(hitbox, damage):
	if landed:
		return
	
	health -= damage
	if health <= 0:
		falling = true
	else:
		animation_player.play("shake")

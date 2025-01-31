extends Area2D

@onready var ray_cast_2d = $ray_cast_2d
@onready var animation_player = $animation_player

var velocity := Vector2(0, 90)

var landed := false

var touched_player := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not landed:
		velocity.y += 150 * delta
		position += velocity * delta
	
		if ray_cast_2d.is_colliding():
			landed = true
			global_position = ray_cast_2d.get_collision_point() - Vector2(0, 24)
			animation_player.play("splash")


func _on_body_entered(body):
	if not touched_player:
		touched_player = true
		
		#heal code here

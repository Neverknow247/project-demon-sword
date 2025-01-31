extends Node2D
class_name Projectile

@export var speed = 250

var velocity = Vector2.ZERO
var velocity_updated = false
var auto_velocity = true

var projectile_type = "n/a"

func update_velocity():
	velocity.x = speed
	velocity = velocity.rotated(rotation)
	velocity_updated = true

func _physics_process(delta):
	if !velocity_updated and auto_velocity:
		update_velocity()
	position += velocity*delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_hitbox_body_entered(body):
	queue_free()

func _on_hitbox_area_entered(area):
	queue_free()

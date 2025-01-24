extends Area2D

@export var damage = 1

var velocity = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta

func _on_area_entered(hurtbox):
	if not hurtbox is Hurtbox:
		return
	hurtbox.take_hit(self, damage)


func _on_life_timer_timeout():
	queue_free()

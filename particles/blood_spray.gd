extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	queue_free()

func set_up(new_parent, hurtbox_pos, hitbox_pos) -> void:
	new_parent.add_child(self)
	global_position = hurtbox_pos
	look_at(hitbox_pos)
	rotation += TAU / 2

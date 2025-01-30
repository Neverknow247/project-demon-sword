extends Area2D

@export var connection : Resource = null
@export var new_level_path : String = ""
var active = true

func _on_body_entered(body):
	if active == true:
		body.emit_signal("hit_door",self)
		active = false

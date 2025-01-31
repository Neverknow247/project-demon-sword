extends Node2D

@onready var animation_player = $animation_player

var destroyed := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hurtbox_hurt(hitbox, damage):
	if not destroyed:
		destroyed = true
		animation_player.play("rupture")
		var blood_orb = preload("res://items/blood_orb.tscn").instantiate()
		get_parent().call_deferred("add_child", blood_orb)
		blood_orb.set_deferred("global_position", global_position + Vector2(3, 14))
		
		#could heal player here, or in blood orb script

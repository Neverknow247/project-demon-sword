extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is DeadCultist:
			child.attack_target = $PlayerPlaceHolder
			child.set_state(DeadCultist.FOLLOWING)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

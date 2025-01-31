extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color("#130310"))
	#for child in get_children():
		#if child is DeadCultist or child is DemonBat:
			#child.attack_target = $player
			#child.set_state(child.process_following)
		#elif child is Eye:
			#child.attack_target = $player
			#child.set_state(child.process_attack)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

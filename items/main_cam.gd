extends Camera2D

@onready var timer = $timer
@onready var fade_screen = $fade_screen

var target
var shake = 0
var transition_time = 1

func _ready():
	fade("in")
	#Events.add_screen_shake.connect(start_screen_shake)

@warning_ignore("unused_parameter")
func _process(delta):
	offset.x = randf_range(-shake, shake)
	offset.y = randf_range(-shake, shake)

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if target:
		global_position = target.global_position

func change_target(new_target):
	target = new_target

func start_screen_shake(amount,duration):
	shake= amount
	timer.start(duration)

func fade(transition):
	var tween = get_tree().create_tween()
	if transition == "in":
		tween.tween_property(fade_screen,"self_modulate",Color("ffffff00"),transition_time)
	else:
		tween.tween_property(fade_screen,"self_modulate",Color("ffffff"),transition_time)

func _on_timer_timeout():
	shake = 0

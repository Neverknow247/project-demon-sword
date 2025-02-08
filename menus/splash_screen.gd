extends Control

var stats = Stats
var utils = Utils
var sounds = Sounds

var next_board = "res://menus/main_menu.tscn"
var easter_sounds = ["meow_1","bell_bronze_ring","angel_1_1","bark_twice"]

@onready var timer = $timer
@onready var easter_egg_button = $never_splash/easter_egg_button

func _ready():
	stats.rng.randomize()
	SaveAndLoad.load_data()
	SaveAndLoad.load_settings()
	utils.set_volume()
	sounds.play_sound("smell_this_bread")

func _on_easter_egg_button_pressed():
	easter_egg_button.disabled = true
	var rand = stats.rng.randi_range(0,easter_sounds.size()-1)
	sounds.play_sound(easter_sounds[rand],1,-(rand*4))

func _on_timer_timeout():
	get_tree().change_scene_to_file(next_board)

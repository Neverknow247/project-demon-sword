extends Node

var rng = RandomNumberGenerator.new()

var dev_mode = false

var cheat_code = null
var cheats = {
	"on" : false,
	"hp" : false
}

signal player_dead()
signal health_changed(value)

var default_max_health = 5
var max_health = default_max_health : set = set_max_health
func set_max_health(value):
	max_health = value

var health = max_health : set = set_health
func set_health(value):
	health = clamp(value,0,max_health)
	health_changed.emit(health)
	if health <= 0 : player_dead.emit()
	#get_tree().change_scene_to_file()


var new_save_data = {
	"version" : ProjectSettings.get_setting("application/config/version"),
	"time" : 0,
	"player_position" : Vector2(232,1792),
	"current_room" : "level_00",
	"music_section" : 0,
	"stats" : {
		"Power On Count" : 0,
		"Towers Attempted" : 0,
		"Steps Taken" : 0,
		"Jumped" : 0,
	},
	"items" : {
		"sword" : false,
		"cannon" : false
	},
	"eggs" : {
		"test" : false,
	},
}

var save_data = return_new_save_data()

func return_new_save_data():
	var new_data = new_save_data.duplicate(true)
	return new_data

func delete_save():
	save_data = return_new_save_data()

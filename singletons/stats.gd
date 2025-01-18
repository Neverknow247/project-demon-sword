extends Node

var rng = RandomNumberGenerator.new()

var dev_mode = false

var cheat_code = null
var cheats = {
	"on" : false,
	"hp" : false
}

var new_save_data = {
	"version" : ProjectSettings.get_setting("application/config/version"),
	"time" : 0,
	"player_position" : Vector2(232,1792),
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

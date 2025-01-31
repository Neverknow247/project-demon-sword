extends Node

@onready var music_player =$music

var music = {
	"before_sword" : load("res://assets/music/shrine.ogg"),
	"after_sword" : load("res://assets/music/carnage.ogg"),
	}

var music_playing = null

func play_music(music_string, pitch_scale = 1, volume_db = 0):
	if music_playing != music_string:
		music_player.pitch_scale = pitch_scale
		music_player.volume_db = volume_db
		music_player.stream = music[music_string]
		music_player.play()
		music_playing = music_string

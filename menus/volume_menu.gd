extends Control

var stats = Stats
var utils = Utils

const master_bus_name = "Master"
const music_bus_name = "Music"
const sounds_bus_name = "Sounds"
const voice_bus_name = "Voice"

signal hide_menu(scene)

@onready var master_bus = AudioServer.get_bus_index(master_bus_name)
@onready var music_bus = AudioServer.get_bus_index(music_bus_name)
@onready var sounds_bus = AudioServer.get_bus_index(sounds_bus_name)
@onready var voice_bus = AudioServer.get_bus_index(voice_bus_name)

@onready var master_slider = $center_container/v_box_container/master/master_slider
@onready var music_slider = $center_container/v_box_container/music/music_slider
@onready var sounds_slider = $center_container/v_box_container/sounds/sounds_slider
@onready var voice_slider = $center_container/v_box_container/voice/voice_slider

var active = false

func _ready():
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sounds_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sounds_bus))
	voice_slider.value = db_to_linear(AudioServer.get_bus_volume_db(voice_bus))

func _on_master_slider_value_changed(value):
	if active:
		AudioServer.set_bus_volume_db(master_bus,linear_to_db(value))
		utils.volume_settings["master_volume"] = value

func _on_music_slider_value_changed(value):
	if active:
		AudioServer.set_bus_volume_db(music_bus,linear_to_db(value))
		utils.volume_settings["music_volume"] = value

func _on_sounds_slider_value_changed(value):
	if active:
		AudioServer.set_bus_volume_db(sounds_bus,linear_to_db(value))
		utils.volume_settings["sounds_volume"] = value

func _on_voice_slider_value_changed(value):
	if active:
		AudioServer.set_bus_volume_db(voice_bus,linear_to_db(value))
		utils.volume_settings["voice_volume"] = value

func _on_back_button_pressed():
	SaveAndLoad.update_settings()
	active = false
	hide_menu.emit(self)

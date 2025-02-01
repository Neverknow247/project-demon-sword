extends Control

var stats = Stats
var sounds = Sounds

@onready var new_game = $margin_container/v_box_container/new_game
@onready var _continue = $margin_container/v_box_container/continue

func _ready():
	SaveAndLoad.load_data()
	_continue.grab_focus()
	sounds.play_music("before_sword")

func _on_new_game_pressed():
	stats.delete_save()
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_quit_pressed():
	get_tree().quit()

extends Control

var stats = Stats
var sounds = Sounds

@onready var new_game = $margin_container/v_box_container/new_game
@onready var _continue = $margin_container/v_box_container/continue

@onready var volume_menu = $volume_menu

func _ready():
	_continue.grab_focus()
	sounds.play_music("before_sword")

func _on_new_game_pressed():
	stats.delete_save()
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	volume_menu.show()
	volume_menu.active = true
	$volume_menu/center_container/v_box_container/master/master_slider.grab_focus()

func _on_volume_menu_hide_menu(scene):
	SaveAndLoad.update_settings()
	scene.hide()
	_continue.grab_focus()

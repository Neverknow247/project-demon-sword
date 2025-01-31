extends Control

var stats = Stats

@onready var new_game = $margin_container/v_box_container/new_game

func _ready():
	SaveAndLoad.load_data()
	new_game.grab_focus()

func _on_new_game_pressed():
	stats.delete_save()
	get_tree().change_scene_to_file("res://levels/world.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://levels/world.tscn")

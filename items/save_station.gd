extends StaticBody2D

var stats = Stats

@export var save_name = "level_00"

@onready var animation_player = $animation_player

func _on_player_sensor_body_entered(body):
	stats["save_data"]["current_room"] = save_name
	stats.heal()
	animation_player.play("animate")
	SaveAndLoad.update_save_data()

extends StaticBody2D

@onready var animation_player = $animation_player

signal save_game

func _on_player_sensor_body_entered(body):
	animation_player.play("animate")
	save_game.emit()

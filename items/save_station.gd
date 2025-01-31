extends StaticBody2D

var stats = Stats

@onready var animation_player = $animation_player

func _on_player_sensor_body_entered(body):
	animation_player.play("animate")
	SaveAndLoad.update_save_data()

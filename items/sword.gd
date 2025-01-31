extends Area2D

var stats = Stats

var item_name = "sword"

func _ready():
	if stats["save_data"]["items"]["sword"] == true:
		queue_free()

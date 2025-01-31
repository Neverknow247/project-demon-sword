extends Area2D

var stats = Stats

var item_name = "cannon"

func _ready():
	if stats["save_data"]["items"]["cannon"] == true:
		queue_free()

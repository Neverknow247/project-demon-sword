extends Node2D

func _ready():
	RenderingServer.set_default_clear_color(Color("#130310"))
	SaveAndLoad.load_data()


func _on_hurtbox_hurt(hitbox, damage):
	print(damage)

extends Node2D

func _ready():
	SaveAndLoad.load_data()


func _on_hurtbox_hurt(hitbox, damage):
	print(damage)

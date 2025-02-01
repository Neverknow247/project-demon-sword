extends Node2D

@export var player : CharacterBody2D
#@export var level_name = "level_00"
@export var save_station = Node2D

@onready var camera_limits = $camera_limits
@onready var enemies = $enemies

func _ready():
	pass
	#set_enemy_target()

func set_enemy_target():
	var fullenemylist = enemies.get_children()
	for list in fullenemylist:
		var enemylist = list.get_children()
		for enemy in enemylist:
			enemy.attack_target = player

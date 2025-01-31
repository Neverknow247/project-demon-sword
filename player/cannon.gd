extends Node2D

var utils = Utils

const cannon_bullet = preload("res://player/cannon_bullet.tscn")

@onready var rotation_point = $rotation_point
@onready var muzzle = $rotation_point/muzzle

func fire_cannon(facing,rotated):
	var new_cannon_bullet = utils.instantiate_scene_on_world(cannon_bullet,muzzle.global_position)
	new_cannon_bullet.rotation = rotation_point.rotation
	if facing == -1 and rotated == 0:
		new_cannon_bullet.speed *= -1
		new_cannon_bullet.scale.x = -1

extends Node2D


var player = CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color("#130310"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	$player.sword_arm_unlocked = true
	$player.check_sword_arm_unlocked()
	$cultists/dead_cultist.detect_player = true
	$cultists/dead_cultist2.detect_player = true
	$cultists/dead_cultist3.detect_player = true
	$cultists/dead_cultist4.detect_player = true
	$cultists/dead_cultist5.detect_player = true
	$cultists/dead_cultist6.detect_player = true

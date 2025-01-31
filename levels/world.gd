extends Node2D

var stats = Stats
var all_save_rooms = All_Save_Rooms.new()

@onready var current_level = $level_00
@onready var main_cam = $player/Camera2D
@onready var player = $player

func _ready():
	RenderingServer.set_default_clear_color(Color("#130310"))
	set_level()
	change_camera_limits(current_level.camera_limits)

func set_level():
	current_level.queue_free()
	var new_level = all_save_rooms["save_rooms"][stats["save_data"]["current_room"]].instantiate()
	new_level.player = player
	add_child(new_level)
	current_level = new_level
	player.global_position = new_level.save_station.global_position
	change_camera_limits(new_level.camera_limits)

func change_levels(door):
	var offset = current_level.position
	current_level.queue_free()
	var new_level_path = load(door.new_level_path)
	var new_level = new_level_path.instantiate()
	new_level.player = player
	add_child(new_level)
	var new_door = get_door_with_connection(door,door.connection)
	var exit_position = new_door.position - offset
	new_level.position = door.position - exit_position
	current_level = new_level
	stats["save_data"]["current_room"] = current_level["level_name"]
	change_camera_limits(new_level.camera_limits)

func get_door_with_connection(old_door, connection):
	var doors = get_tree().get_nodes_in_group("door")
	for door in doors:
		if door.connection == connection and door != old_door:
			return door
	return null

func change_camera_limits(camera_limits):
	main_cam.limit_left = camera_limits.global_position.x
	main_cam.limit_right = camera_limits.global_position.x+camera_limits.size.x
	main_cam.limit_top = camera_limits.global_position.y
	main_cam.limit_bottom = camera_limits.global_position.y+camera_limits.size.y

func _on_player_hit_door(door):
	call_deferred("change_levels",door)

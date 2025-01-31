extends Node
class_name All_Save_Rooms

var stats = Stats
var rng = stats.rng

var save_rooms = {
	"level_00":preload("res://levels/level_00.tscn"),
	"sword_room":preload("res://levels/sword_room.tscn"),
	"save_room_2":preload("res://levels/save_room_2.tscn"),
	"cannon_room":preload("res://levels/cannon_room.tscn"),
	"hidden_room":preload("res://levels/hidden_room.tscn"),
}

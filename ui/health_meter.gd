extends Control

var stats = Stats

var sprite_size = 36

@onready var empty = $empty
@onready var full = $full

func _ready():
	empty.size.x = stats.max_health * sprite_size + 1
	full.size.x = stats.health * sprite_size + 1
	stats.health_changed.connect(_on_health_changed)

func _on_health_changed(value):
	full.size.x = value * sprite_size + 1

extends HBoxContainer

var stats = Stats

@onready var health_display = $health_display
@onready var ammo_display = $ammo_display


func _ready():
	health_display.max_value = stats.max_health
	health_display.value = stats.health
	stats.health_changed.connect(_on_health_changed)

func _on_health_changed(value):
	health_display.value = value

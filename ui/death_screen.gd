extends PanelContainer

@onready var reload = $margin_container/v_box_container/reload
@onready var main_menu = $margin_container/v_box_container/main_menu
@onready var quit = $margin_container/v_box_container/quit

# Called when the node enters the scene tree for the first time.
func _ready():
	reload.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_reload_pressed():
	get_tree().change_scene_to_file("res://levels/world.tscn")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()

extends GridContainer

@export var value := 8:
	set(new_value):
		#if value 
		value = new_value
		for i in get_child_count():
			get_child(i).visible = i < value

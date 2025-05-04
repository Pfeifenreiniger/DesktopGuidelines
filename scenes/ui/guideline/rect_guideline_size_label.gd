extends Label

#-------PROPERTIES-------

const offset_y:float = -50.

var below_screen_y:bool = false:
	get:
		return below_screen_y
	set(value):
		below_screen_y = value
		text_moved = false

var text_moved:bool = true


#-------METHODS: CALLED AT EVERY FRAME-------

func _process(_delta: float) -> void:
	_handle_size_label_position()


#-------METHODS-------

func _handle_size_label_position() -> void:

	if !below_screen_y && !text_moved:
		position.y -= offset_y
		text_moved = true
	
	elif below_screen_y && !text_moved:
		position.y += offset_y
		text_moved = true

extends Node

#-------PROPERTIES-------

var screen_size:Vector2 = Vector2.ZERO


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	_switch_to_desktop_screen_size()


#-------METHODS-------

func _switch_to_desktop_screen_size() -> void:
	screen_size = DisplayServer.screen_get_size()
	_resize_viewport(screen_size)


func _resize_viewport(size:Vector2) -> void:
	pass

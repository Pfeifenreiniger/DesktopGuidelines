extends Node2D

#-----------CUSTOM SIGNALS-----------#

signal monitor_size_changed(new_size)


#-----------PROPERTIES-----------#

# screen and window sizes
var PRIMARY_MONITOR_ID:int = DisplayServer.get_primary_screen()
var WINDOW_SIZE:Vector2i = DisplayServer.window_get_size()
var MONITOR_SIZE:Vector2i = DisplayServer.screen_get_size(PRIMARY_MONITOR_ID):
	get:
		return MONITOR_SIZE
	set(value):
		MONITOR_SIZE = value
		monitor_size_changed.emit(MONITOR_SIZE)
var MONITOR_POSITION:Vector2i = DisplayServer.screen_get_position(PRIMARY_MONITOR_ID)


#-----------PROPERTIES-----------#

func reload(monitor_id:int) -> void:
	WINDOW_SIZE = DisplayServer.window_get_size()
	MONITOR_SIZE = DisplayServer.screen_get_size(monitor_id)
	MONITOR_POSITION = DisplayServer.screen_get_position(monitor_id)

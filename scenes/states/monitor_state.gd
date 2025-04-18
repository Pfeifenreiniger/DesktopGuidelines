extends Node2D

#-----------PROPERTIES-----------#

# screen and window sizes
var PRIMARY_MONITOR_ID:int = DisplayServer.get_primary_screen()
var WINDOW_SIZE:Vector2i = DisplayServer.window_get_size()
var MONITOR_SIZE:Vector2i = DisplayServer.screen_get_size(PRIMARY_MONITOR_ID)
var MONITOR_POSITION:Vector2i = DisplayServer.screen_get_position(PRIMARY_MONITOR_ID)


#-----------PROPERTIES-----------#

func reload(monitor_id:int) -> void:
	WINDOW_SIZE = DisplayServer.window_get_size()
	MONITOR_SIZE = DisplayServer.screen_get_size(monitor_id)
	MONITOR_POSITION = DisplayServer.screen_get_position(monitor_id)

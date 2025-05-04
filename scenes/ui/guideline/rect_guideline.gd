@tool
extends Control
class_name RectGuideline

#-------CUSTOM SIGNALS-------

signal remove_guideline(self_reference)


#-------NODES-------

@onready var resize_button: Button = $ResizeButton as Button
@onready var move_button: Button = $MoveButton as Button
@onready var remove_button: Button = $RemoveButton as Button
@onready var size_label: Label = $SizeLabel as Label


#-------PROPERTIES-------

@export var color := Color.WHITE
@export var min_size := Vector2(30, 30)

var is_resizing := false
var is_moving := false
var drag_offset := Vector2.ZERO

var locked := false:
	get:
		return locked
	set(value):
		locked = value
		if value:
			resize_button.disabled = true
			resize_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			resize_button.tooltip_text = ""
			move_button.disabled = true
			move_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			move_button.tooltip_text = ""
		else:
			resize_button.mouse_default_cursor_shape = Control.CURSOR_DRAG
			resize_button.disabled = false
			resize_button.tooltip_text = "resize rectangle"
			move_button.disabled = false
			move_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			move_button.tooltip_text = "move rectangle"


#-------METHODS: CALLED AT SCENE-ENTRY-------

func _ready() -> void:
	resize_button.modulate = color
	resize_button.mouse_default_cursor_shape = Control.CURSOR_DRAG
	
	move_button.modulate = color
	move_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	remove_button.modulate = color
	remove_button.pressed.connect(_on_remove_button_pressed)
	
	size_label.label_settings.font_color = color
	size_label.text = "Width: %spx\nHeight: %spx" % [str(roundi(size.x)), str(roundi(size.y))]
	
	GuidelinesState.do_hide_guidelines.connect(_on_guidelines_state_do_hide_guidelines)
	GuidelinesState.do_show_pixel_information.connect(_on_guidelines_state_do_show_pixel_information)


#-------METHODS: CALLED AT EVERY FRAME-------

func _draw():
	# Rahmen zeichnen
	draw_rect(Rect2(Vector2.ZERO, size), color, false, 2.0)


func _input(event):
	# mouse clicks events entgegen nehmen
	
	if locked:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if resize_button.get_global_rect().has_point(get_global_mouse_position()):
				is_resizing = event.pressed
				is_moving = false
			elif move_button.get_global_rect().has_point(get_global_mouse_position()):
				is_moving = event.pressed
				drag_offset = get_global_mouse_position() - global_position
				is_resizing = false
			elif get_global_rect().has_point(get_global_mouse_position()):
				if event.pressed:
					drag_offset = get_global_mouse_position() - global_position
				is_resizing = false
				is_moving = false
			else:
				is_resizing = false
				is_moving = false
	
	elif event is InputEventMouseMotion:
		if is_resizing:
			
			# Berechne die maximale Größe basierend auf der aktuellen Position
			var max_size:Vector2 = Vector2(MonitorState.MONITOR_SIZE.x, MonitorState.MONITOR_SIZE.y) - global_position
			var new_size:Vector2 = (get_global_mouse_position() - global_position).clamp(min_size, max_size)
			size = new_size
			size_label.text = "Width: %spx\nHeight: %spx" % [str(roundi(size.x)), str(roundi(size.y))]
			
			_handle_size_label_position()
		
		elif is_moving:
			
			var mouse_pos:Vector2 = get_global_mouse_position()
			var new_pos = mouse_pos - drag_offset
			
			# Position innerhalb der Screen Size begrenzen
			new_pos.x = clamp(
				new_pos.x, 0.0, MonitorState.MONITOR_SIZE.x - size.x
			)
			new_pos.y = clamp(
				new_pos.y, 0.0, MonitorState.MONITOR_SIZE.y - size.y
			)
			
			# neue Position anwenden
			global_position = new_pos
			
			_handle_size_label_position()


#-------METHODS-------

func _handle_size_label_position() -> void:
	
	if global_position.y + size.y + size_label.size.y > MonitorState.MONITOR_SIZE.y:
		if !size_label.below_screen_y:
			size_label.below_screen_y = true
	
	else:
		if size_label.below_screen_y:
			size_label.below_screen_y = false


#-------METHODS: CONNECTED SIGNALS-------

func _on_remove_button_pressed() -> void:
	remove_guideline.emit(self)


func _on_guidelines_state_do_hide_guidelines(status:bool) -> void:
	visible = !status


func _on_guidelines_state_do_show_pixel_information(status:bool) -> void:
	size_label.visible = status

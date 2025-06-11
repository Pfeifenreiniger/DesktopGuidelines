extends Node2D
class_name FreeLineGuideline

#-------CUSTOM SIGNALS-------

signal remove_guideline(self_reference)


#-------NODES-------

@onready var line:Line2D = $Line2D as Line2D
@onready var label:Label = $Label as Label
@onready var remove_button: Button = $RemoveButton as Button
@onready var move_button: Button = $MoveButton as Button
@onready var screen_background: ColorRect = $ScreenBackground as ColorRect


#-------PROPERTIES-------

@export var color := Color.WHITE

var start_point: Vector2
var end_point: Vector2
var has_start := false
var has_line := false

var placing := true
var click_stage := 0

var is_moving := false
var drag_offset := Vector2.ZERO

var locked := false:
	get:
		return locked
	set(value):
		locked = value
		if value:
			move_button.disabled = true
			move_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			move_button.tooltip_text = ""
		else:
			move_button.disabled = false
			move_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			move_button.tooltip_text = "move line"


#-------METHODS: CALLED AT SCENE-ENTRY-------

func _ready() -> void:
	
	#screen_background.visible = true
	screen_background.size = MonitorState.MONITOR_SIZE
	
	var tween:Tween = get_tree().create_tween()
	await tween.tween_property(screen_background, "color:a", .5, .35)
	
	
	line.modulate = color
	
	label.label_settings.font_color = color
	
	move_button.modulate = color
	move_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	remove_button.modulate = color
	
	line.clear_points()
	label.visible = false
	remove_button.visible = false
	move_button.visible = false
	
	GuidelinesState.block_guideline_adds = true
	
	# connect signals
	remove_button.pressed.connect(_on_remove_button_pressed)
	
	GuidelinesState.do_hide_guidelines.connect(_on_guidelines_state_do_hide_guidelines)
	GuidelinesState.do_show_pixel_information.connect(_on_guidelines_state_do_show_pixel_information)


#-------METHODS: CALLED AT EVERY FRAME-------

func _process(_delta) -> void:
	# Live-Vorschau zwischen Klick 1 und 2
	if placing and click_stage == 1:
		line.clear_points()
		line.add_point(start_point)
		var current_end_point:Vector2 = get_global_mouse_position() - global_position
		line.add_point(current_end_point)
		# zeigt das Pixel-Label schon waehrend des Setzens an
		_update_label_placing(current_end_point)


func _input(event) -> void:
	# Tastatureingaben durch Benutzer
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if placing:
			# Platzierung abbrechen
			GuidelinesState.block_guideline_adds = false
			remove_guideline.emit(self)
			label.visible = false
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if move_button.get_global_rect().has_point(get_global_mouse_position()):
				is_moving = event.pressed
				drag_offset = get_global_mouse_position() - global_position
			
			else:
				is_moving = false

			# --- Linien-Punkte setzen ---
			if placing and event.pressed:
				if click_stage == 0:
					start_point = get_global_mouse_position() - global_position
					click_stage += 1
				elif click_stage == 1:
					end_point = get_global_mouse_position() - global_position
					placing = false
					screen_background.visible = false
					click_stage = 0
					_update_line()
					_update_label_placed()
					_update_move_button()
					_update_remove_button()
					GuidelinesState.block_guideline_adds = false
					
		else:
			is_moving = false

	elif event is InputEventMouseMotion:
		if is_moving:
			var mouse_pos:Vector2 = get_global_mouse_position()
			var new_pos:Vector2 = mouse_pos - drag_offset
			
			# wenn neue Position nicht innerhalb des Bildschirms -> raus
			if !_check_position_update(new_pos):
				return
			
			global_position = new_pos
			_update_line()
			_update_label_placed()
			_update_move_button()
			_update_remove_button()


#-------METHODS-------

func _check_position_update(new_position:Vector2) -> bool:
	var pos_1 := new_position + start_point
	var pos_2 := new_position + end_point
	
	var puffer_zone:int = 6 # 6 Pixel Puffer Abstand zu den Monitorraendern
	
	# checke ob Position 1 innerhalb der Screen X Werte liegt
	if pos_1.x + puffer_zone > MonitorState.MONITOR_SIZE.x || pos_1.x - puffer_zone < 0:
		return false
	
	if pos_2.x + puffer_zone > MonitorState.MONITOR_SIZE.x || pos_2.x - puffer_zone < 0:
		return false
	
	# checke ob Position 2 innerhalb der Screen Y Werte liegt
	if pos_1.y + puffer_zone > MonitorState.MONITOR_SIZE.y || pos_1.y - puffer_zone < 0:
		return false
	
	if pos_2.y + puffer_zone > MonitorState.MONITOR_SIZE.y || pos_2.y - puffer_zone < 0:
		return false
	
	return true


func _update_line() -> void:
	line.clear_points()
	line.add_point(start_point)
	line.add_point(end_point)


func _update_label_placing(current_end_point:Vector2) -> void:
	var distance:int = int(start_point.distance_to(current_end_point))
	label.text = "%d px" % distance
	label.global_position = global_position + current_end_point + Vector2(10, -20)
	label.visible = GuidelinesState.show_pixel_information


func _update_label_placed() -> void:
	var distance:int = int(start_point.distance_to(end_point))
	label.text = "%d px" % distance
	label.global_position = global_position + end_point + Vector2(10, -20)
	label.visible = GuidelinesState.show_pixel_information


func _update_move_button() -> void:
	move_button.global_position = global_position + end_point + Vector2(10, 10)
	move_button.visible = true


func _update_remove_button() -> void:
	remove_button.global_position = global_position + start_point + Vector2(10, -20)
	remove_button.visible = true


#-------METHODS: CONNECTED SIGNALS-------

func _on_remove_button_pressed() -> void:
	GuidelinesState.block_guideline_adds = false
	remove_guideline.emit(self)


func _on_guidelines_state_do_hide_guidelines(status:bool) -> void:
	visible = !status


func _on_guidelines_state_do_show_pixel_information(status:bool) -> void:
	label.visible = status

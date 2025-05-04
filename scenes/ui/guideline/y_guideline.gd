extends ColorRect

#-------CUSTOM SIGNALS-------

signal remove_guideline(self_reference)


#-------NODES-------

@onready var grab_area: ColorRect = $GrabArea as ColorRect
@onready var remove_button: Button = $RemoveButton as Button
@onready var mouse_position_label: Label = $MousePositionLabel as Label


#-------PROPERTIES-------

@export var y_position:int = 100

var drag_offset_y:float = .0
var is_dragging:bool = false

var locked:bool = false:
	get:
		return locked
	set(value):
		locked = value
		if value:
			grab_area.mouse_default_cursor_shape = Control.CURSOR_ARROW
		else:
			grab_area.mouse_default_cursor_shape = Control.CURSOR_VSIZE


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	grab_area.modulate = Color(1, 1, 1, 0.01) # nahezu transparent -> empfaengt so noch Mausinputs
	
	# mouse cursor anpassen
	grab_area.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	
	anchor_top = 0
	anchor_bottom = 0
	offset_top = y_position # Y-Achsen-Position
	offset_bottom = y_position + 2
	
	# connect signals
	grab_area.gui_input.connect(_on_grab_area_gui_input)
	grab_area.mouse_exited.connect(_on_grab_area_mouse_exited)
	remove_button.pressed.connect(_on_remove_button_pressed)
	GuidelinesState.do_hide_guidelines.connect(_on_guidelines_state_do_hide_guidelines)


#-------METHODS: PER FRAME CALLED-------

func _process(delta: float) -> void:
	_handle_mouse_position_label_position()


#-------METHODS-------

func _handle_mouse_position_label_position() -> void:
	var offset_y:float = 4.
	
	if global_position.y + mouse_position_label.size.y >= MonitorState.MONITOR_SIZE.y:
		
		if mouse_position_label.position.y != -(mouse_position_label.size.y) - offset_y:
			mouse_position_label.position.y = -(mouse_position_label.size.y) - offset_y
	
	else:
		if mouse_position_label.position.y != offset_y:
			mouse_position_label.position.y = offset_y


#-------METHODS: CONNECTED SIGNALS-------

func _on_grab_area_gui_input(event:InputEvent) -> void:
	
	# zeige Mauszeiger Position im Label an
	if event is InputEventMouseMotion && GuidelinesState.show_pixel_information:
		var pos:Vector2 = event.global_position
		mouse_position_label.text = "X: %s\nY: %s" % [int(pos.x), int(pos.y)]
	
	
	# ab hier potentielles Bewegen der Guideline
	# -> wenn gelockt, dann raus
	if locked:
		return
	
	# damit man nicht zu hoch oder zu niedrig zieht
	if global_position.y + 5 >= MonitorState.MONITOR_SIZE.y:
		global_position.y -= 6
		is_dragging = false
		return
	
	if global_position.y - 5 <= 0:
		global_position.y += 6
		is_dragging = false
		return
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_offset_y = event.position.y
				get_viewport().set_input_as_handled()
			
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		var new_y:float = global_position.y + event.relative.y
		global_position.y = clamp(new_y, 0, get_viewport_rect().size.y - 1)


func _on_grab_area_mouse_exited() -> void:
	# entferne Mauszeiger-Position Label
	mouse_position_label.text = ''


func _on_remove_button_pressed() -> void:
	remove_guideline.emit(self)


func _on_guidelines_state_do_hide_guidelines(status:bool) -> void:
	visible = !status

extends ColorRect

#-------CUSTOM SIGNALS-------

signal remove_guideline(self_reference)


#-------NODES-------

@onready var grab_area: ColorRect = $GrabArea as ColorRect
@onready var remove_button: Button = $RemoveButton as Button


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
			grab_area.mouse_default_cursor_shape = Control.CURSOR_DRAG


#-------METHODS: CALLED AT SCENE ENTRY-------

func _ready() -> void:
	
	grab_area.modulate = Color(1, 1, 1, 0.01) # nahezu transparent -> empfaengt so noch Mausinputs
	
	# mouse cursor anpassen
	grab_area.mouse_default_cursor_shape = Control.CURSOR_DRAG
	
	anchor_top = 0
	anchor_bottom = 0
	offset_top = y_position # Y-Achsen-Position
	offset_bottom = y_position + 1
	
	# connect signals
	grab_area.gui_input.connect(_on_grab_area_gui_input)
	remove_button.pressed.connect(_on_remove_button_pressed)


#-------METHODS: CONNECTED SIGNALS-------

func _on_grab_area_gui_input(event:InputEvent) -> void:
	
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


func _on_remove_button_pressed() -> void:
	print("Entferne mich :)")
	remove_guideline.emit(self)
